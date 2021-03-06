//
//  Stock.swift
//  StocksViewer
//
//  Created by Георгий Кашин on 02.03.2021.
//

import Foundation

final class Stock: Decodable {
    private(set) var ticker: String!
    private(set) var companyName: String!
    private(set) var currentPrice: Decimal!
    private(set) var priceChangePerDay: Decimal!
}

// MARK: CodingKeys
extension Stock {
    enum CodingKeys: String, CodingKey {
        case ticker = "symbol"
        case companyName = "description"
    }
}
