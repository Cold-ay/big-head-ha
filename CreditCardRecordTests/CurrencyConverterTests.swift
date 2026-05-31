import XCTest
@testable import CreditCardRecord

final class CurrencyConverterTests: XCTestCase {
    func testConvertsAssistCurrencyToHKD() throws {
        let hkd = try CurrencyConverter.convertToHKD(amount: Decimal(8500), rateToHKD: Decimal(string: "0.052")!)
        XCTAssertEqual(hkd, Decimal(442))
    }

    func testRejectsZeroRate() {
        XCTAssertThrowsError(try CurrencyConverter.convertToHKD(amount: Decimal(10), rateToHKD: Decimal(0)))
    }
}
