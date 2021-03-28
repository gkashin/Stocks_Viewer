//
//  URLSessionProtocol.swift
//  StocksViewer
//
//  Created by Georgy Kashin on 13.08.2020.
 
//

import Foundation

protocol URLSessionProtocol {
    func dataTask(with request: URLRequest, completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void) -> URLSessionDataTaskProtocol
}


