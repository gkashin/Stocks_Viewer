//
//  WebSocketManager.swift
//  StocksViewer
//
//  Created by Георгий Кашин on 11.03.2021.
//

import Foundation

class WebSocketManager {
    static let shared = WebSocketManager()
    
    private var dataArray = [Stock]()
    
    private let webSocketURL = URL(string: "wss://ws.finnhub.io?token=\(User.active.apiKey)")!
    private let decoder = JSONDecoder()
    private let encoder = JSONEncoder()
    
    private let session: URLSession
    private var socket: URLSessionWebSocketTask!
    
    private init() {
        self.session = URLSession(configuration: .default)
        self.connect()
    }
    
    func connect() {
        socket = session.webSocketTask(with: webSocketURL)
        receiveData() {}
        socket.resume()
    }
    
    func receiveData(completion: @escaping () -> Void) {
        socket.receive { [weak self] result in
            guard let self = self else { return }
            
            switch result {
            case .success(let message):
                switch message {
                case .string(let text):
                    guard let data = text.data(using: .utf8) else { return }
                    self.handle(data)
                case .data(let data):
                    self.handle(data)
                @unknown default:
                    debugPrint("Unknown message")
                }
            case .failure(let error):
                print("Error in receiving message: \(error)")
            }
            self.receiveData() {}
        }
    }
    
    func handle(_ data: Data) {
        guard let jsonDictionary = try? JSONSerialization.jsonObject(with: data) as? [String : Any] else {
            print(#line, #function, "Couldn't decode data from \(data)")
            return
        }
        
        guard let data = jsonDictionary["data"] as? [[String : Any]] else {
            print(#line, #function, "Couldn't get data from \(jsonDictionary)")
            return
        }
        
        guard let lastPrice = data.first!["p"] as? Double, let ticker = data.first!["s"] as? String else {
            print(#line, #function, "Couldn't get data from \(data)")
            return
        }
        
        print(ticker, lastPrice)
    }
    
    func subscribeStocks(_ stocks: [Stock]) {
//        let message = stocks.map { ["type": "subscribe", "symbol": $0.ticker] }
        let msg = ["type": "subscribe", "symbol": "AAPL"]
//        for msg in message {
            do {
                let data = try encoder.encode(msg)
                
                self.socket.send(.data(data)) { err in
                    if err != nil {
                        print(err.debugDescription)
                    }
                }
            } catch {
                print(error)
            }
//        }
    }
    
    func unsubscribeStocks(_ stocks: [Stock]) {
        let message = stocks.map { ["type": "unsubscribe", "symbol": $0.ticker] }
        for msg in message {
            do {
                let data = try encoder.encode(msg)
                
                self.socket.send(.data(data)) { err in
                    if err != nil {
                        print(err.debugDescription)
                    }
                }
            } catch {
                print(error)
            }
        }
    }
}
