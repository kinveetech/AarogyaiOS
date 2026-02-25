import XCTest

@MainActor
final class AarogyaiOSUITests: XCTestCase {
    func testAppLaunches() throws {
        let app = XCUIApplication()
        app.launchArguments = ["-ui-testing"]
        app.launch()
        // App should display the login screen with the app title
        let title = app.staticTexts["Aarogya"]
        XCTAssertTrue(title.waitForExistence(timeout: 15))
    }
}
