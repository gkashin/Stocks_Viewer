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
    private var activityIndicator = UIActivityIndicatorView()
    private var factorForNumberOfVisibleStocks = 1
    private var actualStocksCount: Int {
        return isFiltered ? filteredStocks.count : stocks.count
    }
    private var isSearchBarEmpty: Bool {
        return searchController.searchBar.text?.isEmpty ?? true
    }
   
    var stocks = [Stock]()
    var filteredStocks = [Stock]()
    var stocksView: StocksView!
    var isFiltered: Bool {
        // Search bar is active and text is not empty
        return searchController.isActive && !isSearchBarEmpty
    }
    // Number of stocks that are visible at the table
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
    
    func searchControllerEnabled(enabled: Bool) {
        searchController.searchBar.isUserInteractionEnabled = enabled
    }
    
    
    // MARK: Network
    func loadStocks() {
        // Disable searchController before loading
        searchControllerEnabled(enabled: false)
        // Show activity indicator
        showActivityIndicator()
        
        NetworkManager.shared.getAllStocks { [weak self] result in
            guard let self = self else { return }
            
            switch result {
            case .success(data: let data):
                guard let stocks = data as? [Stock] else { return }
                self.stocks = Array(stocks.sorted(by: { $0.ticker < $1.ticker }))
                
                self.stocksView.reloadTable() {
                    // Hide footer and header if table view is empty
                    self.changeHeaderAndFooterViewsHiddenProperty()
                    let indexes = Array(0..<self.numberOfVisibleStocks)
                    // Load quotes for stocks
                    self.loadQuotes(byIndexes: indexes)
                }
            case .failure(error: let error):
                print(error?.localizedDescription ?? "")
                self.showAlert(error: .unableToLoadStocks) { [weak self] in
                    self?.loadStocks()
                }
            }
        
            // Enable searchController after loading
            self.searchControllerEnabled(enabled: true)
            // Hide activity indicator after loading
            self.hideActivityIndicator()
        }
    }
    
    
    // MARK: Actions
    func addOrRemoveFavouriteStock(index: Int) {
        guard let stock = getStock(at: index) else { return }
    
        // If stock in favourites
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
        setupActivityIndicatorView()
    }
    
    func setupNavigationBar() {
        setupTitle()
        setupSearchController()
    }
    
    func setupSearchController() {
        // Disable searchController initially (enable after loading stocks)
        searchController.searchBar.isUserInteractionEnabled = false
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = StocksViewControllerConstants.searchBarPlaceholder
        // To show searchBar initially
        searchController.automaticallyShowsScopeBar = true
        
        navigationItem.searchController = searchController
        definesPresentationContext = true
    }
    
    func filterContentForSearchText(_ searchText: String?) {
        filteredStocks = stocks
        if let searchText = searchText, !searchText.isEmpty {
            filteredStocks = stocks.filter { $0.companyName.lowercased().contains(searchText.lowercased()) || $0.ticker.lowercased().contains(searchText.lowercased()) }
        }
        
        stocksView.reloadTable()
    }
    
    func setupActivityIndicatorView() {
        // Setup activity indicator
        activityIndicator.style = .medium
        activityIndicator.color = .black
        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(activityIndicator)
        
        NSLayoutConstraint.activate([
            activityIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            activityIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor),
        ])
    }
    
    func showActivityIndicator() {
        DispatchQueue.main.async { [weak self] in
            self?.activityIndicator.startAnimating()
            self?.activityIndicator.isHidden = false
        }
    }
    
    func hideActivityIndicator() {
        DispatchQueue.main.async { [weak self] in
            self?.activityIndicator.stopAnimating()
            self?.activityIndicator.isHidden = true
        }
    }
}

// MARK: Actions
private extension StocksViewController {
    func hideStocks() {
        // Reset factor to one
        factorForNumberOfVisibleStocks = 1
        stocksView.reloadTable()
    }
    
    func showMoreStocks() {
        if numberOfVisibleStocks < actualStocksCount {
            let oldNumberOfVisibleStocks = numberOfVisibleStocks
            // Increment factor by one
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
        guard !stocks.isEmpty else { return }
        let searchText = searchController.searchBar.text
        filterContentForSearchText(searchText)
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
            let stock = stocks[index]
            
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
                        let indexOfStock = self.stocks.firstIndex(of: stock)
                        if indexOfStock != nil {
                            self.stocks[indexOfStock!].quote = quote
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
}

// MARK: UITableViewDelegate
extension StocksViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return StocksViewControllerConstants.cellHeight
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
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

