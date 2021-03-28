//
//  Parameters+Extension.swift
//  StocksViewer
//
//  Created by Georgy Kashin on 17.08.2020.
 
//

import Foundation

extension Parameters {
    var query: String? {
        switch self {
        case .url(let url):
            guard !url.isEmpty else {
                return nil
            }
            
            return url
                .map { key, value in
                    guard let value = value else {
                        return key
                    }
                    return "\(key)=\(value)"
            }.joined(separator: "&")
        }
    }
}
