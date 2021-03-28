//
//  File.swift
//  StocksViewer
//
//  Created by Georgy Kashin on 13.08.2020.
 
//

import Foundation

class File: Codable {
    var name: String
    var fileExtension: FileExtension

    enum FileExtension: String, Codable {
        case json
        case jpg
    }

    init(_ name: String, _ fileExtension: FileExtension) {
        self.name = name
        self.fileExtension = fileExtension
    }

    var data: Data? {
        guard
            let url = Bundle(for: type(of: self)).url(forResource: name, withExtension: fileExtension.rawValue),
            let data = try? Data(contentsOf: url) else {
                return nil
        }
        return data
    }
}
