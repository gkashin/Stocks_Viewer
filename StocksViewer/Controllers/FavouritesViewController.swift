//
//  FavouritesViewController.swift
//  StocksViewer
//
//  Created by Георгий Кашин on 10.03.2021.
//

import UIKit

final class FavouritesViewController: StocksViewController {    
    override func setupTitle() {
        title = StocksViewControllerConstants.favouritesBarButtonTitle
    }
    
    override func loadStocks() {
        stocks = Array(User.active.favouriteStocks)
        stocksView.updateTable()
        loadQuotes()
    }
    
    override func loadQuotes() {
        for stock in stocks {
            
        }
    }
    
    /// Only used for removing stock from favourites
    /// - Parameter index: index of the stock array
    override func addOrRemoveFavouriteStock(index: Int) {
        // Remove stock from User's favourites
        super.addOrRemoveFavouriteStock(index: index)
        // Remove stock locally
        stocks.remove(at: index)
        stocksView.updateTable()
    }
}
