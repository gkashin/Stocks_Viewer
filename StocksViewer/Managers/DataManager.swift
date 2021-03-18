//
//  DataManager.swift
//  StocksViewer
//
//  Created by Георгий Кашин on 09.03.2021.
//

import Foundation

final class DataManager {
    
    // MARK: Stocks
    static func saveStocks(_ stocks: [Stock]) {
        let encoded = try? PropertyListEncoder().encode(stocks)
        UserDefaults.standard.set(encoded, forKey: UserDefaultsKeys.stocks.rawValue)
    }
    
    static func getStocks() -> [Stock] {
        guard let data = UserDefaults.standard.data(forKey: UserDefaultsKeys.stocks.rawValue) else { return [] }
        let stocks = try? PropertyListDecoder().decode([Stock].self, from: data)
        return stocks ?? []
    }
}

// MARK: - UserDefaultsKeys
extension DataManager {
    enum UserDefaultsKeys: String {
        case stocks
    }
}
