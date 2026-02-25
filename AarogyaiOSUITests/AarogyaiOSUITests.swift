import XCTest

@MainActor
final class AarogyaiOSUITests: XCTestCase {
    func testAppLaunches() throws {
        let app = XCUIApplication()
        app.launchArguments = ["-ui-testing"]
        app.launch()
        // App should display the auth screen after failing to fetch user
        let signInButton = app.buttons["Sign In"]
        XCTAssertTrue(signInButton.waitForExistence(timeout: 15))
    }
}
