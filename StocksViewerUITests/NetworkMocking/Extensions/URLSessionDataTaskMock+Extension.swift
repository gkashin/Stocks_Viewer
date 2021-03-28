//
//  URLSessionDataTaskMock+Extension.swift
//  StocksViewer
//
//  Created by Georgy Kashin on 17.08.2020.
 
//

import Foundation

extension URLSessionDataTaskMock: URLSessionDataTaskProtocol {
    func cancel() {
        isResumed = false
    }
    
    func suspend() {
        isResumed = false
    }
    
    func resume() {
        isResumed = true
    }
}
