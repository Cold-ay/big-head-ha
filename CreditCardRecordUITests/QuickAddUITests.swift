import XCTest

final class QuickAddUITests: XCTestCase {
    func testQuickAddScreenShowsCoreFields() {
        let app = XCUIApplication()
        app.launch()

        XCTAssertTrue(app.staticTexts["Quick Add"].exists)
        XCTAssertTrue(app.textFields["quickAdd.amount"].exists)
        XCTAssertTrue(app.textFields["quickAdd.merchant"].exists)
        XCTAssertTrue(app.buttons["quickAdd.save"].exists)
    }
}
