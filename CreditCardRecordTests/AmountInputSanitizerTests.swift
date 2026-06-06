import XCTest
@testable import CreditCardRecord

final class AmountInputSanitizerTests: XCTestCase {
    func testKeepsOnlyNumericAmountCharacters() {
        XCTAssertEqual(AmountInputSanitizer.sanitize("HK$1,234abc.56"), "1234.56")
    }

    func testAllowsOneDecimalSeparatorAndTwoFractionDigits() {
        XCTAssertEqual(AmountInputSanitizer.sanitize("12.345.67"), "12.34")
    }

    func testTreatsCommaAsDecimalWhenNoDotExists() {
        XCTAssertEqual(AmountInputSanitizer.sanitize("98,7"), "98.7")
    }
}
