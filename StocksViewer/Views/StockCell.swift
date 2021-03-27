//
//  StockCell.swift
//  StocksViewer
//
//  Created by Георгий Кашин on 02.03.2021.
//

import UIKit

struct Constants {
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
    }
    
    static let dollarSign = "$"
}

final class StockCell: UITableViewCell {
    static let identifier = "StockCellId"
    
    private var addOrRemoveFavouriteStockAction: ((Int) -> Void)?
    
    private var stock = Stock()
    private var tickerLabel = UILabel()
    private var companyNameLabel = UILabel()
    private var currentPriceLabel = UILabel()
    private var priceChangePerDayLabel = UILabel()
    
    private var addOrRemoveFavouriteStockButton = UIButton()
    
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
        addOrRemoveFavouriteStockButton.tag = index
        addOrRemoveFavouriteStockButton.tintColor = User.active.checkStock(stock) ? Constants.Colors.filledStar : Constants.Colors.notFilledStar
        tickerLabel.text = stock.ticker
        companyNameLabel.text = stock.companyName
        companyNameLabel.font = Constants.Fonts.bodyFontSmall
        companyNameLabel.numberOfLines = 0

        currentPriceLabel.text = Constants.dollarSign + "\(stock.quote?.currentPrice ?? 0)"
        let priceChange = stock.quote?.priceChangePerDay ?? 0
        let previousClosePrice = stock.quote?.previousClosePrice ?? 0
        
        priceChangePerDayLabel.font = Constants.Fonts.bodyFont
        let fraction: Double
        if !previousClosePrice.isZero {
            fraction = abs((priceChange / previousClosePrice).rounded(toPlaces: 2))
        } else {
            fraction = 0.0
        }
        
        var priceChangeText: String
        if priceChange.isZero {
            priceChangePerDayLabel.textColor = Constants.Colors.grayFont
            priceChangeText = "\(abs(priceChange))"
        } else {
            let priceChangePositive = priceChange > 0.0
            priceChangePerDayLabel.textColor = priceChangePositive ? Constants.Colors.greenFont : Constants.Colors.redFont
            priceChangeText = (priceChangePositive ? "+" : "-") + Constants.dollarSign + "\(abs(priceChange))"
        }
        let fractionText = " (\(fraction)%)"
        priceChangePerDayLabel.text = priceChangeText + fractionText
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
        setupLabels()
        setupAddToFavouritesButton()
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
        tickerLabel.translatesAutoresizingMaskIntoConstraints = false
        companyNameLabel.translatesAutoresizingMaskIntoConstraints = false
        currentPriceLabel.translatesAutoresizingMaskIntoConstraints = false
        priceChangePerDayLabel.translatesAutoresizingMaskIntoConstraints = false
        
        let tickerStackView = UIStackView(arrangedSubviews: [tickerLabel, addOrRemoveFavouriteStockButton], axis: .horizontal, spacing: 6)
        let leftSideStackView = UIStackView(arrangedSubviews: [tickerStackView, companyNameLabel], axis: .vertical, spacing: 5)
        leftSideStackView.translatesAutoresizingMaskIntoConstraints = false
        leftSideStackView.alignment = .leading
        contentView.addSubview(leftSideStackView)
        
        // Ticker Label and Company Name Label
        NSLayoutConstraint.activate([
            leftSideStackView.centerYAnchor.constraint(equalTo: self.contentView.centerYAnchor),
            leftSideStackView.leadingAnchor.constraint(equalTo: self.contentView.leadingAnchor, constant: 72),
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
    
    func changeButtonColor() {
        if addOrRemoveFavouriteStockButton.tintColor == Constants.Colors.filledStar {
            addOrRemoveFavouriteStockButton.tintColor = Constants.Colors.notFilledStar
        } else {
            addOrRemoveFavouriteStockButton.tintColor = Constants.Colors.filledStar
        }
    }
    
    func setupAddToFavouritesButton() {
        addOrRemoveFavouriteStockButton.setImage(Constants.Images.star, for: .normal)
        addOrRemoveFavouriteStockButton.tintColor = Constants.Colors.notFilledStar
        
        addOrRemoveFavouriteStockButton.addTarget(self, action: #selector(addToFavouritesButtonTapped(_:)), for: .touchUpInside)
    }
}
