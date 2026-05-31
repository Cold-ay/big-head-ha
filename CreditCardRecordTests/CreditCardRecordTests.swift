import XCTest
@testable import CreditCardRecord

final class CreditCardRecordTests: XCTestCase {
    func testAppNameConstant() {
        XCTAssertEqual(AppConstants.appName, "Credit Card Record")
    }
}
