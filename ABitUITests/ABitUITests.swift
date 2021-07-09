import XCTest

class ABitUITests: XCTestCase {

    let app = XCUIApplication()

    override func setUpWithError() throws {
        continueAfterFailure = true
    }

    override func tearDownWithError() throws { }

    func test_player_switching() throws {
        app.launchArguments.append("-loadPlayerA")
        app.launchArguments.append("-loadPlayerB")
        app.launch()

        let playPauseAllButton = app.buttons["play_pause_all_button"]
        let stopAllButton = app.buttons["stop_all_button"]
        let abToggleButton = app.buttons["ab_logo_toggle"]

        XCTAssert(abToggleButton.value as? String == "Primary selected")
        XCTAssert(playPauseAllButton.value as? String == "play")

        playPauseAllButton.tapOrClick()
        XCTAssert(playPauseAllButton.value as? String == "pause")

        abToggleButton.tapOrClick()
        XCTAssert(abToggleButton.value as? String == "Secondary selected")

        stopAllButton.tapOrClick()
        XCTAssert(playPauseAllButton.isHittable)
    }
}

extension XCUIElement {
    func tapOrClick() {
        #if targetEnvironment(macOS)
        click()
        #else
        tap()
        #endif
    }
}
