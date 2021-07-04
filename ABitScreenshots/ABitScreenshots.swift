import XCTest

class ABitScreenshots: XCTestCase {

    let app = XCUIApplication()

    override func setUpWithError() throws {
        continueAfterFailure = true
        setupSnapshot(app)
    }

    override func tearDownWithError() throws {
        app.launchArguments = []
    }

    func testScreenshotCapture_main_light() throws {
        app.launchArguments.append("-AppleInterfaceStyle")
        app.launchArguments.append("Light")

        app.launch()
        snapshot("main")
    }

    func testScreenshotCapture_main_dark() throws {
        app.launchArguments.append("-AppleInterfaceStyle")
        app.launchArguments.append("Dark")
        app.launch()

        snapshot("main_dark")
    }
}
