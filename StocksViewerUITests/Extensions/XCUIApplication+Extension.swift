//
//  XCUIApplication+Extension.swift
//  StocksViewerUITests
//
//  Created by Георгий Кашин on 28.03.2021.
//

import XCTest

extension XCUIApplication {
    func launch(with sessionMock: URLSessionMock = URLSessionMock(), arguments: [String] = []) {
        launchEnvironment[URLSessionMock.identifier] = sessionMock.json
        launchArguments = arguments
        launch()
    }
}

// MARK: - Launch
extension XCUIApplication {
    func launchWithSuccessLoadStocksResponse() {
        let sessionMock = URLSessionMock(
            responses: [
                .downloadStocks: [
                    Response(File("load-stocks-success-response", .json), error: .none),
                ],
            ]
        )
        
        launch(with: sessionMock, arguments: ["UITestMode"])
    }
}
