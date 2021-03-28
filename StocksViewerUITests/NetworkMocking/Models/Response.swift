//
//  Response.swift
//  StocksViewer
//
//  Created by Georgy Kashin on 13.08.2020.
 
//

import Foundation

struct Response: Codable {
    var file: File?
    var error: NetworkErrors?
    var dataTask: URLSessionDataTaskMock

    init(_ file: File? = nil, error: NetworkErrors? = nil, dataTask: URLSessionDataTaskMock = URLSessionDataTaskMock()) {
        self.file = file
        self.error = error
        self.dataTask = dataTask
    }
}
