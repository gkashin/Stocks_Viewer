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
        self.loadQuotes(onlyVisible: false)
        
        WebSocketManager.shared.subscribeStocks(stocks)
    }
    
    override func viewWillAppear(_ animated: Bool) {}
    
    override func viewWillDisappear(_ animated: Bool) {
        WebSocketManager.shared.unsubscribeStocks(stocks)
    }
    
    /// Only used for removing stock from favourites
    /// - Parameter index: index of the stock array
    override func addOrRemoveFavouriteStock(index: Int) {
        // Remove stock from User's favourites
        super.addOrRemoveFavouriteStock(index: index)
        
        let stock = getStock(at: index)
        // Unsubscribe from removed stock
        WebSocketManager.shared.unsubscribeStocks([stock])
        
        // Remove stock locally
        if isFiltered {
            filteredStocks.removeAll(where: { $0 == stock })
        }
        stocks.removeAll(where: { $0 == stock })
        stocksView.updateTable()
    }
}
