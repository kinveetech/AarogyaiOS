import XCTest

@MainActor
final class AarogyaiOSUITests: XCTestCase {

    private var app: XCUIApplication!

    override func setUp() async throws {
        continueAfterFailure = false
        app = XCUIApplication()
        app.launchArguments = ["-ui-testing"]
    }

    func testAppLaunches() throws {
        app.launch()
        let title = app.staticTexts["Aarogya"]
        XCTAssertTrue(title.waitForExistence(timeout: 15))
    }

    func testLoginScreenShowsPhoneField() throws {
        app.launch()
        let phoneField = app.textFields.firstMatch
        XCTAssertTrue(phoneField.waitForExistence(timeout: 15))
    }

    func testLoginScreenShowsSocialButtons() throws {
        app.launch()
        let continueWithApple = app.buttons.matching(
            NSPredicate(format: "label CONTAINS[c] 'Apple'")
        ).firstMatch
        XCTAssertTrue(continueWithApple.waitForExistence(timeout: 15))
    }
}
