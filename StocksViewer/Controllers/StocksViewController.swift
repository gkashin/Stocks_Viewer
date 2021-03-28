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
    static let searchBarPlaceholder = "Find company or ticker"
    static let cellHeight: CGFloat = 68
    static let initialNumberOfVisibleStocks = 5
}

class StocksViewController: UIViewController {
    
    private let searchController = UISearchController()
    var filteredStocks = [Stock]()
    var isFiltered: Bool {
        return searchController.isActive
    }
    var stocks = [Stock]()
    var stocksView: StocksView!
    private var actualStocksCount: Int {
        return isFiltered ? filteredStocks.count : stocks.count
    }
    var numberOfVisibleStocks: Int {
        return min(actualStocksCount, StocksViewControllerConstants.initialNumberOfVisibleStocks * factorForNumberOfVisibleStocks)
    }
    // Remove factor
    private var factorForNumberOfVisibleStocks = 1

    // MARK: Initializers
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        stocksView = StocksView(viewController: self, showMoreStocksAction: showMoreStocks, hideStocksAction: hideStocks)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        loadStocks()
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // Maybe only update certain rows
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
                    let indexes = Array(0..<self.numberOfVisibleStocks)
                    self.loadQuotes(byIndexes: indexes)
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
    
    func showMoreStocks() {
        if numberOfVisibleStocks < actualStocksCount {
            let oldNumberOfVisibleStocks = numberOfVisibleStocks
            factorForNumberOfVisibleStocks += 1
            print(#line, #function)
            let indexes = Array(oldNumberOfVisibleStocks..<numberOfVisibleStocks)
            stocksView.updateTable() {
                self.loadQuotes(byIndexes: indexes)
            }
        }
    }
    
    func hideStocks() {
        print(#line, #function)
        factorForNumberOfVisibleStocks = 1
        stocksView.updateTable()
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
    
    func loadQuotes(byIndexes indexes: [Int]) {
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
            // Maybe reload rows only
            self?.stocksView.updateTable()
        }
    }
    
//    func loadImages(byIndexes indexes: [Int]) {
//        let downloadGroup = DispatchGroup()
//        for index in indexes {
//            let stock = stocks[index]
//
//            downloadGroup.enter()
//            NetworkManager.shared.getImage(byTicker: stock.ticker) { [weak self] result in
//                switch result {
//                case .success(data: let data):
//                    if let quote = data as? Quote {
//                        // Check if the stock still exists
//                        let indexOfStock = self?.stocks.firstIndex(of: stock)
//                        if indexOfStock != nil {
//                            self?.stocks[indexOfStock!].quote = quote
//                        }
//                    }
//                case .failure(error: let error):
//                    print(error?.localizedDescription ?? "")
//                }
//                downloadGroup.leave()
//            }
//        }
//        downloadGroup.notify(queue: DispatchQueue.main) { [weak self] in
//            // Maybe reload rows only
//            self?.stocksView.updateTable()
//        }
//    }
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
        searchController.searchBar.placeholder = StocksViewControllerConstants.searchBarPlaceholder
        
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
    
    // Observers
    @objc func keyboardWillShow(notification: NSNotification) {
        guard let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue else { return }
        let insets = UIEdgeInsets(top: 0, left: 0, bottom: keyboardSize.height, right: 0)
        stocksView.updateTableViewInsets(with: insets)
    }
    
    @objc func keyboardWillHide() {
        stocksView.updateTableViewInsets(with: .zero)
    }
}

// MARK: - UISearchResultsUpdating
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
        return numberOfVisibleStocks
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: StockCell.identifier, for: indexPath)
        guard let stockCell = cell as? StockCell else { return cell }
        // Configure cell with stock
        let index = indexPath.row
        
        let stock = getStock(at: index)
        stockCell.configure(withStock: stock, index: index, addOrRemoveFavouriteStockAction: addOrRemoveFavouriteStock)
        
        return stockCell
    }
}

