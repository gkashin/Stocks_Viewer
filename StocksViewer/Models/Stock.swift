//
//  Stock.swift
//  StocksViewer
//
//  Created by Георгий Кашин on 02.03.2021.
//

import UIKit

class Quote: Codable {
    var previousClosePrice: Double!
    var currentPrice: Double!
    var priceChangePerDay: Double! {
        return (currentPrice - previousClosePrice).rounded(toPlaces: 2)
    }
    
    enum CodingKeys: String, CodingKey {
        case previousClosePrice = "pc"
        case currentPrice = "c"
    }
}

class Stock: Codable {
    private(set) var ticker: String!
    private(set) var companyName: String!
    var quote: Quote!
}

// MARK: Hashable
extension Stock: Hashable {
    static func == (lhs: Stock, rhs: Stock) -> Bool {
        return lhs.ticker == rhs.ticker
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(ticker)
    }
}

// MARK: CodingKeys
extension Stock {
    enum CodingKeys: String, CodingKey {
        case ticker = "symbol"
        case companyName = "description"
    }
}
