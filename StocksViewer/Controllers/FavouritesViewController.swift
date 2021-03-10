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
        stocksView.updateTable()
    }
}
