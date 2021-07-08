//
//  ABitUITests.swift
//  ABitUITests
//
//  Created by Ed Rutter on 19/09/2020.
//

import XCTest

class ABitUITests: XCTestCase {

    let app = XCUIApplication()

    override func setUpWithError() throws {
        continueAfterFailure = true
    }

    override func tearDownWithError() throws { }

    func test_player_switching() throws {
        app.launch()

        let playPauseAllButton = app.buttons["play_pause_all_button"]
        let stopAllButton = app.buttons["stop_all_button"]
        let abToggleButton = app.buttons["ab_logo_toggle"]

        XCTAssert(abToggleButton.value as? String == "Primary selected")
        XCTAssert(playPauseAllButton.value as? String == "play")

        playPauseAllButton.click()
        XCTAssert(playPauseAllButton.value as? String == "pause")

        abToggleButton.click()
        XCTAssert(abToggleButton.value as? String == "Secondary selected")

        stopAllButton.click()
        XCTAssert(playPauseAllButton.isHittable)
    }
}
