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
        UserDefaults.standard.set(stocks, forKey: UserDefaultsKeys.stocks.rawValue)
    }
    
    static func getStocks() -> [Stock] {
        return UserDefaults.standard.array(forKey: UserDefaultsKeys.stocks.rawValue) as? [Stock] ?? []
    }
}

// MARK: - UserDefaultsKeys
extension DataManager {
    enum UserDefaultsKeys: String {
        case stocks
    }
}
