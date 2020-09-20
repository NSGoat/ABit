//
//  ABitUITests.swift
//  ABitUITests
//
//  Created by Ed Rutter on 19/09/2020.
//

import XCTest

class ABitUITests: XCTestCase {

    override func setUpWithError() throws {
        continueAfterFailure = true
    }

    override func tearDownWithError() throws { }

    func testExample() throws {
        let app = XCUIApplication()
        app.launch()
    }

    func testLaunchPerformance() throws {
        if #available(macOS 10.15, iOS 13.0, tvOS 13.0, *) {
            measure(metrics: [XCTApplicationLaunchMetric()]) {
                XCUIApplication().launch()
            }
        }
    }
}
