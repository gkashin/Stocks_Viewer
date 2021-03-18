//
//  StocksViewController.swift
//  StocksViewer
//
//  Created by Георгий Кашин on 02.03.2021.
//

import UIKit

struct StocksViewControllerConstants {
    static let title = "Stocks"
    static let favouritesBarButtonTitle = "Favourites"
    static let cellHeight: CGFloat = 68
}

class StocksViewController: UIViewController {
    
    var stocks = [Stock]()
    var stocksView: StocksView!
    
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
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        stocksView.updateTable()
    }
    
    override func loadView() {
        self.view = stocksView
    }
    
    func setupTitle() {
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: StocksViewControllerConstants.favouritesBarButtonTitle, style: .done, target: self, action: #selector(favouritesBarButtonTapped))
        title = StocksViewControllerConstants.title
    }
    
    func loadStocks() {
        NetworkManager.shared.getAllStocks { result in
            switch result {
            case .success(data: let data):
                guard let stocks = data as? [Stock] else { return }
                self.stocks = Array(stocks.sorted(by: { $0.ticker < $1.ticker })[...20])
                self.stocksView.updateTable()
                self.loadQuotes()
            case .failure(error: let error):
                print(error?.localizedDescription ?? "")
            }
        }
    }
    
    func addOrRemoveFavouriteStock(index: Int) {
        print(#line, #function, index)
        let stock = stocks[index]
        
        if User.active.checkStock(stock) {
            User.active.removeStockFromFavourites(stock)
        } else {
            User.active.addStockToFavourites(stock)
        }
    }
    
    func loadQuotes() {
//        WebSocketManager.shared.connectToWebSocket()
        
        
        for (index, stock) in stocks.enumerated() {
//            NetworkManager.shared.getQuote(byTicker: stock.ticker) { result in
//                switch result {
//                case .success(data: let data):
//                    guard let currentPrice = data as? Decimal else { return }
//                    self.stocks[index].currentPrice = currentPrice
//                    if index % 10 == 0 {
//                        self.stocksView.updateTable()
//                    }
//                case .failure(error: let error):
//                    print(error?.localizedDescription ?? "")
//                }
//            }
        }
    }
}

// MARK: - Private Methods
// MARK: UI
extension StocksViewController {
    func setupUI() {
        view.backgroundColor = Constants.Colors.background
        setupTitle()
    }
}

// MARK: Actions
private extension StocksViewController {
    @objc func favouritesBarButtonTapped() {
        let favouritesVC = FavouritesViewController()
        navigationController?.pushViewController(favouritesVC, animated: true)
    }
}

// MARK: - Network
private extension StocksViewController {
//    func loadStocks() {
//        NetworkManager.shared.getAllStocks { result in
//            switch result {
//            case .success(data: let data):
//                guard let stocks = data as? [Stock] else { return }
//                self.stocks = stocks.sorted(by: { $0.ticker < $1.ticker })
//                self.stocksView.updateTable()
//            case .failure(error: let error):
//                print(error?.localizedDescription ?? "")
//            }
//        }
//    }
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
        stockCell.configure(withStock: stocks[index], index: index, addOrRemoveFavouriteStockAction: addOrRemoveFavouriteStock)
        
        return stockCell
    }
}

