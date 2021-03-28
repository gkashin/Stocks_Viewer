//
//  Decodable+Extension.swift
//  StocksViewer
//
//  Created by Georgy Kashin on 17.08.2020.
 
//

import Foundation

extension Decodable {
    static func decode(from json: String) -> Self? {
        guard let data = json.data(using: .utf8) else {
            return nil
        }

        return try? JSONDecoder().decode(self, from: data)
    }
}
