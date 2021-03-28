//
//  NetworkErrors.swift
//  StocksViewer
//
//  Created by Georgy Kashin on 17.08.2020.
 
//

import Foundation

enum NetworkErrors: String, Codable, Error {
    case invalidRequest
    case serverError
}
