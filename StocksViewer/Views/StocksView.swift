//
//  StocksView.swift
//  StocksViewer
//
//  Created by Георгий Кашин on 02.03.2021.
//

import UIKit

struct StocksViewConstants {
    static let showMoreButtonTitle = "Show more"
    static let showMoreButtonHeight: CGFloat = 40
}

final class StocksView: UIView {
    private var tableView: UITableView!
    private var showMoreButton = UIButton(type: .system)
    
    private var showMoreStocksAction: (() -> Void)
    
    init(viewController: StocksViewController, showMoreStocksAction: @escaping () -> Void) {
        self.showMoreStocksAction = showMoreStocksAction
        super.init(frame: .zero)
        tableView = UITableView(frame: .zero, style: .insetGrouped)
        tableView.delegate = viewController
        tableView.dataSource = viewController
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // Keyboard Observers

}

// MARK: - Public Methods
extension StocksView {
    func updateTable(completion: (() -> Void)? = nil) {
        DispatchQueue.main.async { [weak self] in
            self?.tableView.reloadData()
            completion?()
        }
    }
    
    func updateTableViewInsets(with insets: UIEdgeInsets) {
        tableView.contentInset = insets
        tableView.scrollIndicatorInsets = insets
    }
}

// MARK: - Private Methods
// MARK: Actions
private extension StocksView {
    @objc func showMoreButtonTapped() {
        showMoreStocksAction()
    }
}

// MARK: UI
private extension StocksView {
    func setupUI() {
        setupShowMoreButton()
        setupTableView()
    }
    
    func setupTableView() {
        self.addSubview(tableView)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.register(StockCell.self, forCellReuseIdentifier: StockCell.identifier)
        
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: self.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: self.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: self.bottomAnchor),
        ])
        
        tableView.tableFooterView = showMoreButton
    }
    
    func setupShowMoreButton() {
        showMoreButton.frame = CGRect(origin: .zero, size: CGSize(width: self.tableView.frame.width, height: StocksViewConstants.showMoreButtonHeight))
        showMoreButton.setTitle(StocksViewConstants.showMoreButtonTitle, for: .normal)
        showMoreButton.addTarget(self, action: #selector(showMoreButtonTapped), for: .touchUpInside)
    }
}
