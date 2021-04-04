//
//  StockCell.swift
//  StocksViewer
//
//  Created by Георгий Кашин on 02.03.2021.
//

import UIKit

struct StockCellConstants {
    struct Colors {
        static let blackFont = #colorLiteral(red: 0.1019607843, green: 0.1019607843, blue: 0.1019607843, alpha: 1)
        static let greenFont = #colorLiteral(red: 0.1411764706, green: 0.6980392157, blue: 0.3647058824, alpha: 1)
        static let redFont = #colorLiteral(red: 0.6980392157, green: 0.1411764706, blue: 0.1411764706, alpha: 1)
        static let grayFont = UIColor.systemGray
        static let background = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
        static let filledStar = UIColor.systemYellow
        static let notFilledStar = UIColor.systemGray
    }
    
    struct Fonts {
        static let headingFont = UIFont.systemFont(ofSize: 18)
        static let bodyFont = UIFont.systemFont(ofSize: 12)
        static let bodyFontSmall = UIFont.systemFont(ofSize: 11)
    }
    
    struct Images {
        static let star = UIImage(systemName: "star.fill")
        static let stock = UIImage(named: "stock")!
    }

    static let dollarSign = "$"
}

final class StockCell: UITableViewCell {
    
    // MARK: Stored Properties
    static let identifier = "StockCellId"
    
    private var addOrRemoveFavouriteStockAction: ((Int) -> Void)?
    
    private var stock = Stock()
    
    private var tickerLabel = UILabel()
    private var companyNameLabel = UILabel()
    private var currentPriceLabel = UILabel()
    private var priceChangePerDayLabel = UILabel()
    private var stockImageView = UIImageView()
    
    private var addOrRemoveFavouriteStockButton = UIButton()
    
    
    // MARK: Initializers
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: - Public Methods
extension StockCell {
    func configure(withStock stock: Stock, index: Int, addOrRemoveFavouriteStockAction: @escaping (Int) -> (Void)) {
        self.addOrRemoveFavouriteStockAction = addOrRemoveFavouriteStockAction
        
        // Buttons
        addOrRemoveFavouriteStockButton.tag = index
        addOrRemoveFavouriteStockButton.tintColor = User.current.checkStock(stock) ? StockCellConstants.Colors.filledStar : StockCellConstants.Colors.notFilledStar
        
        // Labels
        tickerLabel.text = stock.ticker
        companyNameLabel.text = stock.companyName
        // Move font to setupUI
        companyNameLabel.font = StockCellConstants.Fonts.bodyFontSmall
        companyNameLabel.numberOfLines = 0
        let roundedCurrentPrice = stock.quote?.currentPrice.rounded(toPlaces: 2) ?? 0
        currentPriceLabel.text = StockCellConstants.dollarSign + "\(roundedCurrentPrice)"
        priceChangePerDayLabel.font = StockCellConstants.Fonts.bodyFont

        let priceChange = stock.quote?.priceChangePerDay ?? 0
        let previousClosePrice = stock.quote?.previousClosePrice ?? 0
        
        // Setup priceChangePerDayLabel color
        setupPriceChangePerDayLabelColor(priceChange: priceChange)

        let percentText = getPercentText(previousClosePrice: previousClosePrice, priceChange: priceChange)
        let priceChangeText = getPriceChangeText(priceChange: priceChange)
        
        priceChangePerDayLabel.text = priceChangeText + percentText
    }
    
    func setupPriceChangePerDayLabelColor(priceChange: Double) {
        if priceChange.isZero {
            priceChangePerDayLabel.textColor = StockCellConstants.Colors.grayFont
        } else {
            let priceChangePositive = priceChange > 0.0
            priceChangePerDayLabel.textColor = priceChangePositive ? StockCellConstants.Colors.greenFont : StockCellConstants.Colors.redFont
        }
    }
    
    func getPercentText(previousClosePrice: Double, priceChange: Double) -> String {
        var percent: Double
        if !previousClosePrice.isZero {
            let fraction = abs(priceChange / previousClosePrice)
            // Convert to percent (* 100%)
            percent = (100 * fraction).rounded(toPlaces: 2)
        } else {
            percent = 0.0
        }
        return " (\(percent)%)"
    }
    
    func getPriceChangeText(priceChange: Double) -> String {
        var priceChangeText: String
        if priceChange.isZero {
            priceChangeText = "\(StockCellConstants.dollarSign)\(abs(priceChange))"
        } else {
            let priceChangePositive = priceChange > 0.0
            priceChangeText = (priceChangePositive ? "+" : "-") + StockCellConstants.dollarSign + "\(abs(priceChange))"
        }
        return priceChangeText
    }
}

// MARK: Actions
private extension StockCell {
    @objc func addToFavouritesButtonTapped(_ sender: UIButton) {
        addOrRemoveFavouriteStockAction?(sender.tag)
        changeButtonColor()
    }
}

// MARK: - Private Methods
// MARK: UI
private extension StockCell {
    func setupUI() {
        setupImageView()
        setupLabels()
        setupAddToFavouritesButton()
    }
    
    func setupImageView() {
        stockImageView.image = StockCellConstants.Images.stock
        stockImageView.contentMode = .scaleAspectFill
        
        stockImageView.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(stockImageView)
        NSLayoutConstraint.activate([
            stockImageView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 12),
            stockImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 12),
            stockImageView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -12),
        ])
    }
    
    func setupLabels() {
        addLabels()
        setupLabelsConstraints()
    }
    
    func addLabels() {
        contentView.addSubview(tickerLabel)
        contentView.addSubview(companyNameLabel)
        contentView.addSubview(currentPriceLabel)
        contentView.addSubview(priceChangePerDayLabel)
    }
    
    func setupLabelsConstraints() {
        currentPriceLabel.translatesAutoresizingMaskIntoConstraints = false
        priceChangePerDayLabel.translatesAutoresizingMaskIntoConstraints = false
        
        // Stack Views
        let tickerStackView = UIStackView(arrangedSubviews: [tickerLabel, addOrRemoveFavouriteStockButton], axis: .horizontal, spacing: 6)
        let leftSideStackView = UIStackView(arrangedSubviews: [tickerStackView, companyNameLabel], axis: .vertical, spacing: 5)
        leftSideStackView.translatesAutoresizingMaskIntoConstraints = false
        leftSideStackView.alignment = .leading
        contentView.addSubview(leftSideStackView)
        
        NSLayoutConstraint.activate([
            leftSideStackView.centerYAnchor.constraint(equalTo: self.contentView.centerYAnchor),
            leftSideStackView.leadingAnchor.constraint(equalTo: self.stockImageView.trailingAnchor, constant: 12),
        ])

        // Price Change Per Day Label
        priceChangePerDayLabel.setContentCompressionResistancePriority(.required, for: .horizontal)
        NSLayoutConstraint.activate([
            priceChangePerDayLabel.bottomAnchor.constraint(equalTo: self.contentView.bottomAnchor, constant: -14),
            priceChangePerDayLabel.trailingAnchor.constraint(equalTo: self.contentView.trailingAnchor, constant: -12),
            priceChangePerDayLabel.leadingAnchor.constraint(equalTo: leftSideStackView.trailingAnchor, constant: 5),
        ])
        
        // Current Price Label
        NSLayoutConstraint.activate([
            currentPriceLabel.topAnchor.constraint(equalTo: self.contentView.topAnchor, constant: 14),
            currentPriceLabel.trailingAnchor.constraint(equalTo: self.contentView.trailingAnchor, constant: -17),
        ])
    }
    
    func setupAddToFavouritesButton() {
        addOrRemoveFavouriteStockButton.setImage(StockCellConstants.Images.star, for: .normal)
        addOrRemoveFavouriteStockButton.tintColor = StockCellConstants.Colors.notFilledStar
        
        addOrRemoveFavouriteStockButton.addTarget(self, action: #selector(addToFavouritesButtonTapped(_:)), for: .touchUpInside)
    }
    
    func changeButtonColor() {
        if addOrRemoveFavouriteStockButton.tintColor == StockCellConstants.Colors.filledStar {
            addOrRemoveFavouriteStockButton.tintColor = StockCellConstants.Colors.notFilledStar
        } else {
            addOrRemoveFavouriteStockButton.tintColor = StockCellConstants.Colors.filledStar
        }
    }
}
