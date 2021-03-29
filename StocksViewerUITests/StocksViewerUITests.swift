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

// MARK: - General
extension StocksViewerUITests {
    func testLoadStocksSuccess() throws {
        app.launchWithSuccessLoadStocksResponse()
        
        XCTAssertTrue(app.tables.staticTexts["AAC TECHNOLOGIES HOLDINGS IN"].waitForExistence(timeout: 1))
        XCTAssertTrue(app.tables.staticTexts["ARIZONA METALS CORP"].exists)
        XCTAssertTrue(app.tables.staticTexts["CLINIGEN GROUP PLC"].exists)
    }
}

// MARK: - Search
extension StocksViewerUITests {
    func testSearch() throws {
        app.launchWithSuccessLoadStocksResponse()
        
        // Given
        let tablesQuery = app.tables
        let navigationBar = app.navigationBars["Stocks"]
        let searchBar = navigationBar.searchFields["Find company or ticker"]
            
        // When
        app.swipeDown()
        searchBar.tap()
        searchBar.typeText("CLINIGEN")
        
        // Then
        XCTAssertTrue(tablesQuery.cells.count == 1)
    }
}

// MARK: - Buttons
extension StocksViewerUITests {
    func testShowMoreButton() throws {
        app.launchWithSuccessLoadStocksResponse()
        
        // When
        app.buttons["Show more"].tap()
        
        // Then
        XCTAssertTrue(app.cells.count == 20)
    }
    
    func testHideButton() throws {
        app.launchWithSuccessLoadStocksResponse()
        
        // Given
        app.buttons["Show more"].tap()
        app.buttons["Show more"].tap()
        
        // When
        app.buttons["Hide"].tap()
        
        // Then
        XCTAssertTrue(app.cells.count == 10)
    }
}

// MARK: - Favourites
extension StocksViewerUITests {
    func testAddStockToFavourites() throws {
        app.launchWithSuccessLoadStocksResponse()
        
        // When
        app.tables.cells.containing(.staticText, identifier: "CLIGF").buttons["favorite"].tap()
        app.navigationBars["Stocks"].buttons["Favourites"].tap()
        
        // Then
        XCTAssertTrue(app.tables.staticTexts["CLIGF"].waitForExistence(timeout: 1))
    }
    
    func testRemoveStockFromFavourites() throws {
        app.launchWithSuccessLoadStocksResponse()
        
        // Given
        let tablesQuery = app.tables
        tablesQuery.cells.containing(.staticText, identifier: "CLIGF").buttons["favorite"].tap()
        app.navigationBars["Stocks"].buttons["Favourites"].tap()
        
        // When
        tablesQuery.cells.containing(.staticText, identifier: "CLIGF").buttons["favorite"].tap()
        
        // Then
        XCTAssertFalse(tablesQuery.cells.containing(.staticText, identifier: "CLIGF").buttons["favorite"].waitForExistence(timeout: 1))
    }
    
    func testAddStockToFavouritesInSearch() throws {
        app.launchWithSuccessLoadStocksResponse()
        
        // Given
        let tablesQuery = app.tables
        let navigationBar = app.navigationBars["Stocks"]
        let searchBar = navigationBar.searchFields["Find company or ticker"]
            
        // When
        app.swipeDown()
        searchBar.tap()
        searchBar.typeText("CLINIGEN")
        tablesQuery.cells.containing(.staticText, identifier: "CLIGF").buttons["favorite"].tap()
        navigationBar.buttons["Cancel"].tap()
        app.navigationBars["Stocks"].buttons["Favourites"].tap()
        
        // Then
        XCTAssertTrue(tablesQuery.cells.containing(.staticText, identifier: "CLIGF").buttons["favorite"].waitForExistence(timeout: 1))
    }
    
    func testRemoveStockFromFavouritesInSearch() throws {
        app.launchWithSuccessLoadStocksResponse()
        
        // Given
        let tablesQuery = app.tables
        let navigationBar = app.navigationBars["Favourites"]
        let searchBar = navigationBar.searchFields["Find company or ticker"]
            
        tablesQuery.cells.containing(.staticText, identifier: "CFNCF").buttons["favorite"].tap()
        app.navigationBars["Stocks"].buttons["Favourites"].tap()
        
        // When
        app.swipeDown()
        searchBar.tap()
        searchBar.typeText("COMPAGNIE FINANCIERE")
        tablesQuery.cells.containing(.staticText, identifier: "CFNCF").buttons["favorite"].tap()
        
        // Then
        XCTAssertFalse(tablesQuery.cells.containing(.staticText, identifier: "CFNCF").buttons["favorite"].waitForExistence(timeout: 1))
    }
}
