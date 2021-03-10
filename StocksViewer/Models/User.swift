//
//  User.swift
//  StocksViewer
//
//  Created by Георгий Кашин on 08.03.2021.
//

import Foundation

final class User {
    static let shared = User()
    
    private(set) var favouriteStockTickers = Set<String>() {
        didSet {
            DataManager.saveTickers(Array(favouriteStockTickers))
        }
    }
    
    private init() {
        let tickers = DataManager.getTickers()
        favouriteStockTickers = Set(tickers)
    }

    func addStockToFavourites(with ticker: String) {
        favouriteStockTickers.insert(ticker)
    }
    
    func removeStockFromFavourites(with ticker: String) {
        favouriteStockTickers.remove(ticker)
    }
    
    func checkTicker(_ ticker: String) -> Bool {
        return favouriteStockTickers.contains(ticker)
    }
}
