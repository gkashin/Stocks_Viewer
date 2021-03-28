//
//  URLSession+Extension.swift
//  StocksViewer
//
//  Created by Georgy Kashin on 17.08.2020.
 
//

import Foundation

extension URLSession: URLSessionProtocol {
    func dataTask(with request: URLRequest, completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void) -> URLSessionDataTaskProtocol {
        return dataTask(with: request, completionHandler: completionHandler) as URLSessionDataTask
    }
}
