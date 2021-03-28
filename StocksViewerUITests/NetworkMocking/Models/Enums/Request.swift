//
//  Request.swift
//  StocksViewer
//
//  Created by Georgy Kashin on 17.08.2020.
 
//

import Foundation

enum Request: Hashable {
    case downloadStocks
    
    var url: String {
        switch self {
        case .downloadStocks:
            return "https://finnhub.io/api/v1/stock/symbol"
        }
    }
    
    var method: HTTPMethod {
        switch self {
        case .downloadStocks:
            return .get
        }
    }
    
    var parameters: Parameters {
        switch self {
        case .downloadStocks:
            return .url(["exchange": "US", "token": User.active.apiKey])
        }
    }
    
    var absoluteUrl: String {
        guard let query = parameters.query else {
            return url
        }
        
        return "\(url)?\(query)"
    }
}
