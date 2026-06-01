import XCTest

final class RepaymentUITests: XCTestCase {
    func testRepaymentTabExists() {
        let app = XCUIApplication()
        app.launchArguments.append("--uitesting")
        app.launch()
        app.tabBars.buttons["Repayment"].tap()
        XCTAssertTrue(app.navigationBars["Repayment"].exists)
        XCTAssertTrue(app.staticTexts["Next Payment Due"].exists)
    }
}
