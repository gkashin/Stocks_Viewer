//
//  WebSocketManager.swift
//  StocksViewer
//
//  Created by Георгий Кашин on 11.03.2021.
//

import Foundation

class WebSocketManager {
    static let shared = WebSocketManager()
    private init(){}
    
    private var dataArray = [Stock]()
    
    private let decoder = JSONDecoder()
    private let encoder = JSONEncoder()
    
    private let webSocketTask = URLSession(configuration: .default).webSocketTask(with: URL(string: "wss://ws.finnhub.io?token=c109iuf48v6t383m4pe0")!)
    
    func connectToWebSocket() {
        webSocketTask.resume()
        self.listen()
        self.sendRequest()
    }
    
    func listen() {
        webSocketTask.receive { [weak self] result in
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
            self.listen()
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
        
        guard let lastPrice = data.first!["p"] as? Double else {
            print(#line, #function, "Couldn't get current price from \(data)")
            return
        }
        
        print(lastPrice)
    }
    
    func sendRequest() {
        let message = ["type":"subscribe","symbol":"AAPL"]
        do {
            let data = try encoder.encode(message)
            
            self.webSocketTask.send(.data(data)) { err in
                if err != nil {
                    print(err.debugDescription)
                }
            }
        } catch {
            print(error)
        }
    }
}
