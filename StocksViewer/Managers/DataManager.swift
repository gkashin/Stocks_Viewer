//
//  DataManager.swift
//  StocksViewer
//
//  Created by Георгий Кашин on 09.03.2021.
//

import Foundation

final class DataManager {
    
    // MARK: Stocks
    static func saveTickers(_ tickers: [String]) {
        UserDefaults.standard.set(tickers, forKey: UserDefaultsKeys.tickers.rawValue)
    }
    
    static func getTickers() -> [String] {
        return UserDefaults.standard.stringArray(forKey: UserDefaultsKeys.tickers.rawValue) ?? []
    }
}

// MARK: - UserDefaultsKeys
extension DataManager {
    enum UserDefaultsKeys: String {
        case tickers
    }
}
