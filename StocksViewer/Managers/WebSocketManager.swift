//
//  WebSocketManager.swift
//  StocksViewer
//
//  Created by Георгий Кашин on 11.03.2021.
//

import Foundation

class WebSocketManager {
    
    // MARK: Stored Properties
    static let shared = WebSocketManager()
        
    private let webSocketURL = URL(string: "wss://ws.finnhub.io?token=\(User.current.apiKey)")!
    private let decoder = JSONDecoder()
    private let encoder = JSONEncoder()
    
    private let session: URLSession
    private var dataArray = [Stock]()
    private var socket: URLSessionWebSocketTask!
    
    
    // MARK: Initializers
    private init() {
        self.session = URLSession(configuration: .default)
        socket = session.webSocketTask(with: webSocketURL)
        resumeUpdating()
    }
    
    
    // MARK: Network Methods
    private func handle(_ data: Data) -> [String: Any]? {
        guard let jsonDictionary = try? JSONSerialization.jsonObject(with: data) as? [String : Any] else {
            print(#line, #function, "Couldn't decode data from \(data)")
            return nil
        }
        
        guard let data = jsonDictionary["data"] as? [[String : Any]] else {
            print(#line, #function, "Couldn't get data from \(jsonDictionary)")
            return nil
        }
        
        guard let lastPrice = data.first!["p"] as? Double, let ticker = data.first!["s"] as? String else {
            print(#line, #function, "Couldn't get data from \(data)")
            return nil
        }
        
        return ["ticker": ticker, "lastPrice": lastPrice]
    }
    
    func resumeUpdating() {
        socket.resume()
    }
    
    func stopUpdating() {
        socket.suspend()
    }
    
    func receiveData(completion: @escaping ([String: Any]?) -> Void) {
        var quoteInfo: [String: Any]? = ["ticker": "", "lastPrice": 0.0]
        
        socket.receive { [weak self] result in
            guard let self = self else { return }
            
            switch result {
            case .success(let message):
                switch message {
                case .string(let text):
                    guard let data = text.data(using: .utf8) else { return }
                    quoteInfo = self.handle(data)
                case .data(let data):
                    quoteInfo = self.handle(data)
                @unknown default:
                    debugPrint("Unknown message")
                }
            case .failure(let error):
                print("Error in receiving message: \(error)")
            }
            completion(quoteInfo)
            self.receiveData(completion: completion)
        }
    }
    
    func subscribeStocks(_ stocks: [Stock]) {
        let message = stocks.map { ["type": "subscribe", "symbol": $0.ticker] }
        for msg in message {
            do {
                let data = try encoder.encode(msg)
                
                self.socket.send(.data(data)) { err in
                    if err != nil {
                        print(#line, #function, err.debugDescription)
                    }
                }
            } catch {
                print(#line, #function, error)
            }
        }
    }
    
    func unsubscribeStocks(_ stocks: [Stock]) {
        let message = stocks.map { ["type": "unsubscribe", "symbol": $0.ticker] }
        for msg in message {
            do {
                let data = try encoder.encode(msg)
                
                self.socket.send(.data(data)) { err in
                    if err != nil {
                        print(#line, #function, err.debugDescription)
                    }
                }
            } catch {
                print(#line, #function, error)
            }
        }
    }
}
