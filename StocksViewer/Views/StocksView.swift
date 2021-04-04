//
//  StocksView.swift
//  StocksViewer
//
//  Created by Георгий Кашин on 02.03.2021.
//

import UIKit

struct StocksViewConstants {
    static let showMoreButtonTitle = "Show more"
    static let hideStocksButtonTitle = "Hide"
    static let standardButtonsHeight: CGFloat = 40
    static let rightInset: CGFloat = 20
}

final class StocksView: UIView {
    
    // MARK: Stored Properties    
    private var tableView: UITableView!
    private var showMoreButton = UIButton(type: .system)
    private var hideStocksButton = UIButton(type: .system)
    
    private var showMoreStocksAction: (() -> Void)
    private var hideStocksAction: (() -> Void)
    
    
    // MARK: Initializers
    init(viewController: StocksViewController, showMoreStocksAction: @escaping () -> Void, hideStocksAction: @escaping () -> Void) {
        self.showMoreStocksAction = showMoreStocksAction
        self.hideStocksAction = hideStocksAction
        super.init(frame: .zero)
        tableView = UITableView(frame: .zero, style: .insetGrouped)
        tableView.delegate = viewController
        tableView.dataSource = viewController
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: - Public Methods
extension StocksView {
    func reloadTable(completion: (() -> Void)? = nil) {
        DispatchQueue.main.async { [weak self] in
            self?.tableView.reloadData()
            completion?()
        }
    }
    
    func updateTableViewInsets(with insets: UIEdgeInsets) {
        tableView.contentInset = insets
        tableView.scrollIndicatorInsets = insets
    }
    
    func setHeaderAndFooterViewsHidden(isHidden: Bool) {
        tableView.tableHeaderView?.isHidden = isHidden
        tableView.tableFooterView?.isHidden = isHidden
    }
    
    func reloadRow(at index: Int) {
        DispatchQueue.main.async { [weak self] in
            let indexPath = IndexPath(row: index, section: 0)
            if self?.tableView.cellForRow(at: indexPath) != nil {
                self?.tableView.reloadRows(at: [indexPath], with: .none)
            }
        }
    }
}

// MARK: - Private Methods
// MARK: Actions
private extension StocksView {
    @objc func showMoreButtonTapped() {
        showMoreStocksAction()
    }
    
    @objc func hideStocksButtonTapped() {
        hideStocksAction()
    }
}

// MARK: UI
private extension StocksView {
    func setupUI() {
        setupButtons()
        setupTableView()
    }
    
    func setupButtons() {
        setupShowMoreButton()
        setupHideStocksButton()
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
        
        tableView.tableHeaderView = hideStocksButton
        tableView.tableFooterView = showMoreButton
    }
    
    func setupShowMoreButton() {
        showMoreButton.frame = CGRect(origin: .zero, size: CGSize(width: self.tableView.frame.width, height: StocksViewConstants.standardButtonsHeight))
        showMoreButton.setTitle(StocksViewConstants.showMoreButtonTitle, for: .normal)
        showMoreButton.addTarget(self, action: #selector(showMoreButtonTapped), for: .touchUpInside)
    }
    
    func setupHideStocksButton() {
        hideStocksButton.frame = CGRect(origin: .zero, size: CGSize(width: self.tableView.frame.width, height: StocksViewConstants.standardButtonsHeight))
        hideStocksButton.contentHorizontalAlignment = .trailing
        hideStocksButton.titleEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: StocksViewConstants.rightInset)
        hideStocksButton.setTitle(StocksViewConstants.hideStocksButtonTitle, for: .normal)
        hideStocksButton.addTarget(self, action: #selector(hideStocksButtonTapped), for: .touchUpInside)
    }
}
