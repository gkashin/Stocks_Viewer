//
//  ProcessInfo+Extension.swift
//  StocksViewer
//
//  Created by Georgy Kashin on 17.08.2020.
 
//

import Foundation

extension ProcessInfo {
    func decode<T: Identifiable & Decodable>(_: T.Type) -> T? {
        guard
            let environment = environment[T.identifier],
            let codable = T.decode(from: environment) else {
                return nil
        }
        
        return codable
    }
}
