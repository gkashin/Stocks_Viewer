//
//  UILabel+Extension.swift
//  StocksViewer
//
//  Created by Георгий Кашин on 02.03.2021.
//

import UIKit

extension UILabel {
    convenience init(text: String, textColor: UIColor = StockCellConstants.Colors.blackFont, font: UIFont = StockCellConstants.Fonts.headingFont) {
        self.init()
        self.text = text
        self.font = font
        self.textColor = textColor
    }
}
