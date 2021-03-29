//
//  FavouritesViewController.swift
//  StocksViewer
//
//  Created by Георгий Кашин on 10.03.2021.
//

import UIKit

final class FavouritesViewController: StocksViewController {
    
    // MARK: UIViewController Methods
    override func viewWillAppear(_ animated: Bool) {
        changeHeaderAndFooterViewsHiddenProperty()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        // Suspend websocket task
        WebSocketManager.shared.stopUpdating()
    }
    
    
    // MARK: Actions
    /// Only used for removing stock from favourites
    /// - Parameter index: index of the stock array
    override func addOrRemoveFavouriteStock(index: Int) {
        // Remove stock from User's favourites
        super.addOrRemoveFavouriteStock(index: index)
        
        guard let stock = getStock(at: index) else { return }
        // Unsubscribe from removed stock
        WebSocketManager.shared.unsubscribeStocks([stock])
        
        // Remove stock locally
        if isFiltered {
            filteredStocks.removeAll(where: { $0 == stock })
        }
        
        stocks.removeAll(where: { $0 == stock })
        changeHeaderAndFooterViewsHiddenProperty()
        stocksView.reloadTable()
    }
    
    
    // MARK: UI
    override func setupTitle() {
        title = StocksViewControllerConstants.favouritesBarButtonTitle
    }
 
    
    // MARK: Networks
    override func loadStocks() {
        stocks = Array(User.current.favouriteStocks)
        // Resume websocket
        WebSocketManager.shared.resumeUpdating()
        // Get data via websocket
        WebSocketManager.shared.receiveData { [weak self] quoteInfo in
            if let self = self, quoteInfo != nil {
                let ticker = quoteInfo!["ticker"] as! String
                let lastPrice = quoteInfo!["lastPrice"] as! Double
                // Update stock with last price
                if let index = self.stocks.firstIndex(where: { $0.ticker == ticker }) {
                    self.stocks[index].quote?.currentPrice = lastPrice
                    self.stocksView.reloadRow(at: index)
                }
            }
        }
        
        // Subscribe for stocks
        WebSocketManager.shared.subscribeStocks(stocks)
        self.loadQuotes(byIndexes: Array(0..<numberOfVisibleStocks))
    }
}
