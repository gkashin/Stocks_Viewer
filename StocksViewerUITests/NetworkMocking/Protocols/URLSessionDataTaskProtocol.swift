//
//  URLSessionDataTaskProtocol.swift
//  StocksViewer
//
//  Created by Georgy Kashin on 13.08.2020.
 
//

import Foundation

protocol URLSessionDataTaskProtocol {
    func resume()
    func cancel()
    func suspend()
}

