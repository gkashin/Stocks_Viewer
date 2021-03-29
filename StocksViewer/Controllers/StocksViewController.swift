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
    static let initialNumberOfVisibleStocks = 10
}

class StocksViewController: UIViewController {
    
    // MARK: Stored Properties
    private let searchController = UISearchController()
    private var factorForNumberOfVisibleStocks = 1
    private var actualStocksCount: Int {
        return isFiltered ? filteredStocks.count : stocks.count
    }
   
    var stocks = [Stock]()
    var filteredStocks = [Stock]()
    var stocksView: StocksView!
    var isFiltered: Bool {
        return searchController.isActive
    }
    var numberOfVisibleStocks: Int {
        return min(actualStocksCount, StocksViewControllerConstants.initialNumberOfVisibleStocks * factorForNumberOfVisibleStocks)
    }


    // MARK: Initializers
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        stocksView = StocksView(viewController: self, showMoreStocksAction: showMoreStocks, hideStocksAction: hideStocks)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    // MARK: UIViewController Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        loadStocks()
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        changeHeaderAndFooterViewsHiddenProperty()
        stocksView.reloadTable()
    }
    
    override func loadView() {
        self.view = stocksView
    }
    
    
    // MARK: - Overridable
    // MARK: UI
    func setupTitle() {
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: StocksViewControllerConstants.favouritesBarButtonTitle, style: .done, target: self, action: #selector(favouritesBarButtonTapped))
        title = StocksViewControllerConstants.title
    }
    
    func changeHeaderAndFooterViewsHiddenProperty() {
        if stocks.count == 0 {
            stocksView.setHeaderAndFooterViewsHidden(isHidden: true)
        } else {
            stocksView.setHeaderAndFooterViewsHidden(isHidden: false)
        }
    }
    
    
    // MARK: Network
    func loadStocks() {
        NetworkManager.shared.getAllStocks { result in
            switch result {
            case .success(data: let data):
                guard let stocks = data as? [Stock] else { return }
                self.stocks = Array(stocks.sorted(by: { $0.ticker < $1.ticker }))
                print(#line, #function, stocks.count)
                
                self.stocksView.reloadTable() {
                    self.changeHeaderAndFooterViewsHiddenProperty()
                    let indexes = Array(0..<self.numberOfVisibleStocks)
                    self.loadQuotes(byIndexes: indexes)
                }
            case .failure(error: let error):
                print(error?.localizedDescription ?? "")
            }
        }
    }
    
    
    // MARK: Actions
    func addOrRemoveFavouriteStock(index: Int) {
        guard let stock = getStock(at: index) else { return }
    
        if User.current.checkStock(stock) {
            WebSocketManager.shared.unsubscribeStocks([stock])
            User.current.removeStockFromFavourites(stock)
        } else {
            User.current.addStockToFavourites(stock)
        }
    }
}

// MARK: - Private Methods
// MARK: UI
private extension StocksViewController {
    func setupUI() {
        view.backgroundColor = StockCellConstants.Colors.background
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
        // To show searchBar initially
        searchController.automaticallyShowsScopeBar = true
        
        navigationItem.searchController = searchController
        definesPresentationContext = true
    }
    
    func filterContentForSearchText(_ searchText: String) {
        filteredStocks = stocks
        if !searchText.isEmpty {
            filteredStocks = stocks.filter { $0.companyName.lowercased().contains(searchText.lowercased()) || $0.ticker.lowercased().contains(searchText.lowercased()) }
        }
        
        stocksView.reloadTable()
    }
}

// MARK: Actions
private extension StocksViewController {
    func hideStocks() {
        factorForNumberOfVisibleStocks = 1
        stocksView.reloadTable()
    }
    
    func showMoreStocks() {
        if numberOfVisibleStocks < actualStocksCount {
            let oldNumberOfVisibleStocks = numberOfVisibleStocks
            factorForNumberOfVisibleStocks += 1
            let indexes = Array(oldNumberOfVisibleStocks..<numberOfVisibleStocks)
            stocksView.reloadTable() {
                self.loadQuotes(byIndexes: indexes)
            }
        }
    }
    
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

// MARK: - Public Methods
// MARK: UISearchResultsUpdating
extension StocksViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        NSObject.cancelPreviousPerformRequests(withTarget: self, selector: #selector(updateSearch), object: nil)
        self.perform(#selector(updateSearch), with: nil, afterDelay: 0.5)
    }
    
    @objc func updateSearch() {
        guard let searchText = searchController.searchBar.text else { return }
        filterContentForSearchText(searchText)
        let indexes = Array(0..<self.numberOfVisibleStocks)
        loadQuotes(byIndexes: indexes)
    }
}

// MARK: Support Methods
extension StocksViewController {
    func getStock(at index: Int) -> Stock? {
        var stock: Stock
        if isFiltered {
            guard index >= 0 && index < filteredStocks.count else { return nil }
            stock = filteredStocks[index]
        } else {
            guard index >= 0 && index < stocks.count else { return nil }
            stock = stocks[index]
        }
        return stock
    }
}

// MARK: Network
extension StocksViewController {
    func loadQuotes(byIndexes indexes: [Int]) {
        let downloadGroup = DispatchGroup()
        for index in indexes {
            guard let stock = getStock(at: index) else { continue }
            
            downloadGroup.enter()
            NetworkManager.shared.getQuote(byTicker: stock.ticker) { [weak self] result in
                guard let self = self else {
                    downloadGroup.leave()
                    return
                }
                switch result {
                case .success(data: let data):
                    if let quote = data as? Quote {
                        // Check if the stock still exists
                        if self.isFiltered {
                            let indexOfStock = self.filteredStocks.firstIndex(of: stock)
                            if indexOfStock != nil {
                                self.filteredStocks[indexOfStock!].quote = quote
                            }
                        } else {
                            let indexOfStock = self.stocks.firstIndex(of: stock)
                            if indexOfStock != nil {
                                self.stocks[indexOfStock!].quote = quote
                            }
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
            self?.stocksView.reloadTable()
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
    //            self?.stocksView.reloadTable()
    //        }
    //    }
}

// MARK: UITableViewDelegate
extension StocksViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return StocksViewControllerConstants.cellHeight
    }
}

// MARK: UITableViewDataSource
extension StocksViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return numberOfVisibleStocks
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: StockCell.identifier, for: indexPath)
        guard let stockCell = cell as? StockCell else { return cell }
        // Configure cell with stock
        let index = indexPath.row
        
        guard let stock = getStock(at: index) else { return cell }
        stockCell.configure(withStock: stock, index: index, addOrRemoveFavouriteStockAction: addOrRemoveFavouriteStock)
        
        return stockCell
    }
}

