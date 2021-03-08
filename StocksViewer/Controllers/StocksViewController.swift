//
//  StocksViewController.swift
//  StocksViewer
//
//  Created by Георгий Кашин on 02.03.2021.
//

import UIKit

private struct StocksViewControllerConstants {
    static let title = "Stocks"
    static let cellHeight: CGFloat = 68
}

class StocksViewController: UIViewController {
    
    private var stocks = [Stock]()
    private var stocksView: StocksView!
    
    // MARK: Initializers
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        stocksView = StocksView(viewController: self)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loadStocks()
        setupUI()
    }
    
    override func loadView() {
        self.view = stocksView
    }
}

// MARK: - Private Methods
// MARK: UI
private extension StocksViewController {
    func setupUI() {
        view.backgroundColor = Constants.Colors.background
        // Setup title
        navigationController?.navigationBar.prefersLargeTitles = true
        title = StocksViewControllerConstants.title
    }
}

// MARK: Actions
private extension StocksViewController {
    func addToFavourites(index: Int) -> Bool {
        print(#line, #function, index)
        guard let ticker = stocks[index].ticker else { return false }
        
        if User.shared.checkTicker(ticker) {
            User.shared.removeStockFromFavourites(with: ticker)
        } else {
            User.shared.addStockToFavourites(with: ticker)
        }
        
        return true
    }
}

// MARK: Network
private extension StocksViewController {
    func loadStocks() {
        NetworkManager.shared.getAllStocks { result in
            switch result {
            case .success(data: let data):
                guard let stocks = data as? [Stock] else { return }
                self.stocks = stocks
                self.stocksView.updateTable()
            case .failure(error: let error):
                print(error?.localizedDescription ?? "")
            }
        }
    }
}

// MARK: - UITableViewDelegate
extension StocksViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return StocksViewControllerConstants.cellHeight
    }
}

// MARK: - UITableViewDataSource
extension StocksViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return stocks.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: StockCell.identifier, for: indexPath)
        guard let stockCell = cell as? StockCell else { return cell }
        // Configure cell with stock
        let index = indexPath.row
        stockCell.configure(withStock: stocks[index], index: index, addToFavouritesAction: addToFavourites)
        
        return stockCell
    }
}

