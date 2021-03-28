//
//  URLSessionMock.swift
//  StocksViewer
//
//  Created by Georgy Kashin on 13.08.2020.
 
//

import Foundation

final class URLSessionMock: Codable {
    var responses: [String: [Response]]

    init(responses: [Request: [Response]] = [:]) {
        self.responses = Dictionary(uniqueKeysWithValues:
            responses.map { request, responses in
                return (key: request.absoluteUrl, value: responses.reversed())
            }
        )
    }
}
