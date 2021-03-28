//
//  URLSessionMock+Extension.swift
//  StocksViewer
//
//  Created by Georgy Kashin on 17.08.2020.
 
//

import Foundation

extension URLSessionMock: Identifiable {}

extension URLSessionMock: URLSessionProtocol {
    func dataTask(with request: URLRequest, completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void) -> URLSessionDataTaskProtocol {
        guard
            let url = request.url?.absoluteString,
            let response = responses[url]?.popLast() else {
                completionHandler(nil, nil, NetworkErrors.invalidRequest)
                
                return URLSessionDataTaskMock()
        }
        
        let successResponseStatusCode200 = HTTPURLResponse(url: request.url!, statusCode: 200, httpVersion: nil, headerFields: nil)
        completionHandler(response.file?.data, successResponseStatusCode200, response.error)
        
        return response.dataTask
    }
}
