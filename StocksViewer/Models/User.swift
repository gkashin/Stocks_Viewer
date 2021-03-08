//
//  User.swift
//  StocksViewer
//
//  Created by Георгий Кашин on 08.03.2021.
//

import Foundation

class User {
    static let shared = User()
    private var favouriteStockTickers = Set<String>()
    
    private init() {}

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
