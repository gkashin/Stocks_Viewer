//
//  NetworkManager.swift
//  StocksViewer
//
//  Created by Георгий Кашин on 04.03.2021.
//

import UIKit

enum Result {
    case success(data: Any? = nil)
    case failure(error: Error? = nil)
}

final class NetworkManager {
    
    // MARK: Stored Properties
    static let shared = NetworkManager()
    private let baseURL = URL(string: "https://finnhub.io/api/v1/")!
    
    let decoder = JSONDecoder()
    
    // MARK: Initializers
    private init() {}
}

// MARK: - Stocks GET
extension NetworkManager {
    func getAllStocks(completion: @escaping (Result) -> ()) {
        let getStocksURL = baseURL.appendingPathComponent("stock/symbol")
        
        var urlComponents = URLComponents(url: getStocksURL, resolvingAgainstBaseURL: true)
        
        urlComponents?.queryItems = [
            URLQueryItem(name: "exchange", value: "US"),
            URLQueryItem(name: "token", value: User.active.apiKey),
        ]
        
        guard let getStocksURLWithQuery = urlComponents?.url else {
            print(#line, #function, "Failed to form url with query")
            return completion(.failure())
        }
        
        var request = URLRequest(url: getStocksURLWithQuery)
        request.httpMethod = "GET"
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            let httpResponse = response as? HTTPURLResponse
            
            guard error == nil else {
                print(#line, #function, error!.localizedDescription)
                return completion(.failure(error: error!))
            }
            
            guard httpResponse?.statusCode == 200 else {
                print(#line, #function, "Failed with response code \(String(describing: httpResponse?.statusCode))")
                return completion(.failure())
            }
            
            guard let data = data else {
                print(#line, #function, "Couldn't get data from \(getStocksURLWithQuery)")
                return completion(.failure())
            }
            
            guard let stocks = try? self.decoder.decode([Stock].self, from: data) else {
                print(#line, #function, "Couldn't decode data from \(data)")
                return completion(.failure())
            }
            
            completion(.success(data: stocks))
        }.resume()
    }
    
    func getQuote(byTicker ticker: String, completion: @escaping (Result) -> Void) {
        let getQuoteURL = baseURL.appendingPathComponent("quote")
        
        var urlComponents = URLComponents(url: getQuoteURL, resolvingAgainstBaseURL: true)
        
        urlComponents?.queryItems = [
            URLQueryItem(name: "symbol", value: ticker),
            URLQueryItem(name: "token", value: User.active.apiKey),
        ]
        
        guard let getQuoteURLWithQuery = urlComponents?.url else {
            print(#line, #function, "Failed to form url with query")
            return completion(.failure())
        }
        
        var request = URLRequest(url: getQuoteURLWithQuery)
        request.httpMethod = "GET"
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            let httpResponse = response as? HTTPURLResponse
            
            guard error == nil else {
                print(#line, #function, error!.localizedDescription)
                return completion(.failure(error: error!))
            }
            
            guard httpResponse?.statusCode == 200 else {
                print(#line, #function, "Failed with response code \(String(describing: httpResponse?.statusCode))")
                return completion(.failure())
            }
            
            guard let data = data else {
                print(#line, #function, "Couldn't get data from \(getQuoteURLWithQuery)")
                return completion(.failure())
            }
            
            guard let quote = try? self.decoder.decode(Quote.self, from: data) else {
                print(#line, #function, "Couldn't decode data from \(data)")
                return completion(.failure())
            }
            
//            guard let jsonDictionary = try? JSONSerialization.jsonObject(with: data) as? [String : Any] else {
//                print(#line, #function, "Couldn't decode data from \(data)")
//                return completion(.failure())
//            }
//
//            guard let previousClosePrice = jsonDictionary[Stock.CodingKeys.previousClosePrice.rawValue] as? Double else {
//                print(#line, #function, "Couldn't get previous close price from \(jsonDictionary)")
//                return completion(.failure())
//            }
            
            completion(.success(data: quote))
        }.resume()
    }
}
