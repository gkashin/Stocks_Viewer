//
//  StocksViewerUITests.swift
//  StocksViewerUITests
//
//  Created by Георгий Кашин on 02.03.2021.
//

import XCTest

final class StocksViewerUITests: XCTestCase {

    private var app: XCUIApplication!
    
    override func setUp() {
        super.setUp()
        app = XCUIApplication()
        
        // In UI tests it is usually best to stop immediately when a failure occurs.
        continueAfterFailure = false
    }

    override func tearDown() {
        super.tearDown()
        app = nil
    }
}

extension StocksViewerUITests {
    func testLoadStocksSuccess() throws {
        app.launchWithSuccessLoadStocksResponse()
        
        XCTAssertTrue(app.tables.staticTexts["APPLE INC"].waitForExistence(timeout: 1))
        XCTAssertTrue(app.tables.staticTexts["UAN POWER CORP"].exists)
        XCTAssertTrue(app.tables.staticTexts["EXCO TECHNOLOGIES LTD"].exists)
    }
    
    func testAddStockToFavourites() throws {
        app.launchWithSuccessLoadStocksResponse()
        
        // When
        app.tables.cells.containing(.staticText, identifier: "APPLE INC").buttons["favorite"].tap()
        app.navigationBars["Stocks"].buttons["Favourites"].tap()
        
        // Then
        XCTAssertTrue(app.tables.staticTexts["APPLE INC"].waitForExistence(timeout: 1))
    }
    
    // TODO: - Check color of star
    func testRemoveStockFromFavourites() {
        app.launchWithSuccessLoadStocksResponse()
        
        // Given
        let tablesQuery = app.tables
        tablesQuery.cells.containing(.staticText, identifier: "APPLE INC").buttons["favorite"].tap()
        app.navigationBars["Stocks"].buttons["Favourites"].tap()
        
        // When
        tablesQuery.cells.containing(.staticText, identifier: "APPLE INC").buttons["favorite"].tap()
        
        // Then
        XCTAssertFalse(tablesQuery.cells.containing(.staticText, identifier: "APPLE INC").buttons["favorite"].waitForExistence(timeout: 1))
    }
}
