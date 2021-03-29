//
//  StockCellTests.swift
//  StockCellTests
//
//  Created by Георгий Кашин on 02.03.2021.
//

import XCTest
@testable import StocksViewer

class StockCellTests: XCTestCase {

    private var sut: StockCell!
    
    override func setUp() {
        super.setUp()
        sut = StockCell()
    }

    override func tearDown() {
        super.tearDown()
        sut = nil
    }
}

extension StockCellTests {
    func testGetFractionText() {
        let previousClosePrices = [0.0, 10.23, -100.4439]
        let priceChanges = [192.232, -123.43, 0.0]
        let results = [" (0.0%)", " (12.07%)", " (0.0%)"]
        
        for i in 0..<results.count {
            let fraction = sut.getFractionText(previousClosePrice: previousClosePrices[i], priceChange: priceChanges[i])
            XCTAssertEqual(fraction, results[i])
        }
    }
    
    func testGetPriceChangeText() {
        let priceChanges = [0.0, -123.43, 145.3]
        let results = ["$0.0", "-$123.43", "+$145.3"]
        
        for i in 0..<results.count {
            let priceChangeText = sut.getPriceChangeText(priceChange: priceChanges[i])
            XCTAssertEqual(priceChangeText, results[i])
        }
    }
}
