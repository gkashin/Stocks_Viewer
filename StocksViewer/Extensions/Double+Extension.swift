//
//  Double+Extension.swift
//  StocksViewer
//
//  Created by Георгий Кашин on 20.03.2021.
//

import Foundation

extension Double {
    func rounded(toPlaces places: Int) -> Double {
        let divisor = pow(10.0, Double(places))
        return (self * divisor).rounded() / divisor
    }
}
