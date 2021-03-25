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
    
    private let searchController = UISearchController()
    var filteredStocks = [Stock]()
    var isFiltered: Bool {
        return searchController.isActive
    }
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
        setupUI()
        loadStocks()
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
                self.stocks = Array(stocks.sorted(by: { $0.ticker < $1.ticker }))
                self.stocksView.updateTable() {
                    self.loadQuotes(onlyVisible: true)
                }
            case .failure(error: let error):
                print(error?.localizedDescription ?? "")
            }
        }
    }
    
    func addOrRemoveFavouriteStock(index: Int) {
        print(#line, #function, index)
        let stock = getStock(at: index)
        
        if User.active.checkStock(stock) {
            User.active.removeStockFromFavourites(stock)
        } else {
            User.active.addStockToFavourites(stock)
        }
    }
    
    func getStock(at index: Int) -> Stock {
        var stock: Stock
        if isFiltered {
            stock = filteredStocks[index]
        } else {
            stock = stocks[index]
        }
        return stock
    }
    
    func loadQuotes(onlyVisible: Bool) {
        var indexes: [Int]
        if onlyVisible {
            indexes = self.stocksView.getIndexesForVisibleRows()
        } else {
            indexes = Array(0..<stocks.count)
        }
        
        let downloadGroup = DispatchGroup()
        for index in indexes {
            let stock = stocks[index]
            
            downloadGroup.enter()
            NetworkManager.shared.getQuote(byTicker: stock.ticker) { [weak self] result in
                switch result {
                case .success(data: let data):
                    if let quote = data as? Quote {
                        // Check if the stock still exists
                        let indexOfStock = self?.stocks.firstIndex(of: stock)
                        if indexOfStock != nil {
                            self?.stocks[indexOfStock!].quote = quote
                        }
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
}

// MARK: - Private Methods
// MARK: UI
private extension StocksViewController {
    func setupUI() {
        view.backgroundColor = Constants.Colors.background
        setupNavigationBar()
    }
    
    func setupNavigationBar() {
        setupTitle()
        setupSearchController()
    }
    
    func setupSearchController() {
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "Search"
        
        navigationItem.searchController = searchController
        definesPresentationContext = true
    }
    
    func filterContentForSearchText(_ searchText: String) {
        filteredStocks = stocks
        if !searchText.isEmpty {
            filteredStocks = stocks.filter { $0.companyName.lowercased().contains(searchText.lowercased()) || $0.ticker.lowercased().contains(searchText.lowercased()) }
        }
        
        stocksView.updateTable()
    }
}

// MARK: Actions
private extension StocksViewController {
    @objc func favouritesBarButtonTapped() {
        let favouritesVC = FavouritesViewController()
        navigationController?.pushViewController(favouritesVC, animated: true)
    }
}

extension StocksViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        let searchBar = searchController.searchBar
        filterContentForSearchText(searchBar.text!)
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
        return isFiltered ? filteredStocks.count : stocks.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: StockCell.identifier, for: indexPath)
        guard let stockCell = cell as? StockCell else { return cell }
        // Configure cell with stock
        let index = indexPath.row
        
        var stock: Stock
        if isFiltered {
            stock = filteredStocks[index]
        } else {
            stock = stocks[index]
        }
        stockCell.configure(withStock: stock, index: index, addOrRemoveFavouriteStockAction: addOrRemoveFavouriteStock)
        
        return stockCell
    }
}

