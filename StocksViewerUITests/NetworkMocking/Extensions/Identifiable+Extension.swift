//
//  Identifiable+Extension.swift
//  StocksViewer
//
//  Created by Georgy Kashin on 17.08.2020.
 
//

import Foundation

extension Identifiable {
    static var identifier: String {
        return String(describing: self)
    }
}
