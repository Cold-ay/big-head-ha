import XCTest

final class QuickAddUITests: XCTestCase {
    func testQuickAddScreenShowsCoreFields() {
        let app = XCUIApplication()
        app.launch()

        XCTAssertTrue(app.staticTexts["Quick Add"].exists)
        XCTAssertTrue(app.textFields["Amount"].exists)
        XCTAssertTrue(app.textFields["Merchant"].exists)
        XCTAssertTrue(app.buttons["Save Transaction"].exists)
    }
}
