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
        
//        WebSocketManager.shared.connectToWebSocket()
//        WebSocketManager.shared.subscribeStocks(stocks)
    }
    
    override func loadQuotes() {
        let downloadGroup = DispatchGroup()
        for (index, stock) in stocks.enumerated() {
            downloadGroup.enter()
            NetworkManager.shared.getQuote(byTicker: stock.ticker) { result in
                switch result {
                case .success(data: let data):
                    if let quote = data as? Quote {
                        self.stocks[index].quote = quote
                    }
                case .failure(error: let error):
                    print(error?.localizedDescription ?? "")
                }
                downloadGroup.leave()
            }
        }
        
        downloadGroup.notify(queue: DispatchQueue.main) { [weak self] in
            self?.stocksView.updateTable()
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        WebSocketManager.shared.unsubscribeStocks(stocks)
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
