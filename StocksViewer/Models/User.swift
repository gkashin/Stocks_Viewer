//
//  User.swift
//  StocksViewer
//
//  Created by Георгий Кашин on 08.03.2021.
//

import Foundation

final class User {
    static let active = User()
    
    private(set) var favouriteStocks = Set<Stock>() {
        didSet {
            DataManager.saveStocks(Array(favouriteStocks))
        }
    }
    
    private init() {
        let stocks = DataManager.getStocks()
        favouriteStocks = Set(stocks)
    }

    func addStockToFavourites(_ stock: Stock) {
        favouriteStocks.insert(stock)
    }
    
    func removeStockFromFavourites(_ stock: Stock) {
        favouriteStocks.remove(stock)
    }
    
    func checkStock(_ stock: Stock) -> Bool {
        return favouriteStocks.contains(stock)
    }
}
