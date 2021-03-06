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
        static let background = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
        static let filledStar = UIColor.systemYellow
        static let notFilledStar = UIColor.systemGray
    }
    
    struct Fonts {
        static let headingFont = UIFont.systemFont(ofSize: 18)
        static let bodyFont = UIFont.systemFont(ofSize: 12)
    }
    
    struct Images {
        static let star = UIImage(systemName: "star.fill")
    }
}

final class StockCell: UITableViewCell {
    static let identifier = "StockCellId"
    
    private var addToFavouritesAction: (() -> Void)?
    private var addedToFavourites = false
    
    private var tickerLabel = UILabel()
    private var companyNameLabel = UILabel()
    private var currentPriceLabel = UILabel()
    private var priceChangePerDayLabel = UILabel()
    
    private var addToFavouritesButton = UIButton()
    
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
    func configure(withStock stock: Stock, addToFavouritesAction: @escaping () -> Void) {
        // TODO: -
        // Add stock property for color
        // Bug with selecting favourites
        
        self.addToFavouritesAction = addToFavouritesAction
        tickerLabel.text = stock.ticker
        companyNameLabel.text = stock.companyName
        companyNameLabel.font = Constants.Fonts.bodyFont
    
//        currentPriceLabel = UILabel(text: "\(String(describing: stock.currentPrice))")
//        let textColor = stock.priceChangePerDay < 0 ? Constants.Colors.redFont : Constants.Colors.greenFont
//        priceChangePerDayLabel = UILabel(text: "\(String(describing: stock.priceChangePerDay))", textColor: textColor, font: Constants.Fonts.bodyFont)
    }
}

// MARK: Actions
private extension StockCell {
    @objc func addToFavouritesButtonTapped() {
        addedToFavourites.toggle()
        addToFavouritesButton.tintColor = addedToFavourites ? Constants.Colors.filledStar : Constants.Colors.notFilledStar
        addToFavouritesAction?()
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
        
        // Ticker Label
        NSLayoutConstraint.activate([
            tickerLabel.topAnchor.constraint(equalTo: self.contentView.topAnchor, constant: 14),
            tickerLabel.leadingAnchor.constraint(equalTo: self.contentView.leadingAnchor, constant: 72),
        ])
        
        // Company Name Label
        NSLayoutConstraint.activate([
            companyNameLabel.bottomAnchor.constraint(equalTo: self.contentView.bottomAnchor, constant: -14),
            companyNameLabel.leadingAnchor.constraint(equalTo: self.contentView.leadingAnchor, constant: 72),
        ])
        
        // Current Price Label
        NSLayoutConstraint.activate([
            currentPriceLabel.topAnchor.constraint(equalTo: self.contentView.topAnchor, constant: 14),
            currentPriceLabel.trailingAnchor.constraint(equalTo: self.contentView.trailingAnchor, constant: -17),
        ])
    }
    
    func setupAddToFavouritesButton() {
        contentView.addSubview(addToFavouritesButton)
        setupAddToFavouritesButtonConstraints()
        addToFavouritesButton.setImage(Constants.Images.star, for: .normal)
        addToFavouritesButton.tintColor = Constants.Colors.notFilledStar
        
        addToFavouritesButton.addTarget(self, action: #selector(addToFavouritesButtonTapped), for: .touchUpInside)
    }
    
    func setupAddToFavouritesButtonConstraints() {
        addToFavouritesButton.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            addToFavouritesButton.centerYAnchor.constraint(equalTo: self.tickerLabel.centerYAnchor),
            addToFavouritesButton.leadingAnchor.constraint(equalTo: self.tickerLabel.trailingAnchor, constant: 6),
        ])
    }
}
