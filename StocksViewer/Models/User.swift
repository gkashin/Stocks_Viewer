//
//  User.swift
//  StocksViewer
//
//  Created by Георгий Кашин on 08.03.2021.
//

import Foundation

final class User {
    
    // MARK: Stored Properties
    static let current = User()
    let apiKey = "c1cq1fv48v6vagf170jg"
    
    private(set) var favouriteStocks = Set<Stock>() {
        didSet {
            DataManager.saveStocks(Array(favouriteStocks))
        }
    }
    
    
    // MARK: Initializers
    private init() {
        let stocks = DataManager.getStocks()
        favouriteStocks = Set(stocks)
    }

    
    // MARK: Actions with Stocks
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
