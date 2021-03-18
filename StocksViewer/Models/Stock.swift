//
//  Stock.swift
//  StocksViewer
//
//  Created by Георгий Кашин on 02.03.2021.
//

import Foundation

struct Stock: Decodable {
    private(set) var ticker: String!
    private(set) var companyName: String!
    var currentPrice: Decimal!
    private(set) var priceChangePerDay: Decimal!
}

extension Stock: Hashable {
    static func == (lhs: Stock, rhs: Stock) -> Bool {
        return lhs.ticker == rhs.ticker
    }
}

// MARK: CodingKeys
extension Stock {
    enum CodingKeys: String, CodingKey {
        case ticker = "symbol"
        case companyName = "description"
        case currentPrice = "c"
    }
}
