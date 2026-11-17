import XCTest
@testable import CreditCardRecord

final class CurrencyConverterTests: XCTestCase {
    func testTaiwanCurrencyConvertsWithoutLosingOriginalAmount() throws {
        XCTAssertEqual(try CurrencyConverter.convertToHKD(amount: 1000, rateToHKD: Decimal(string: "0.24")!), 240)
    }

    func testAmountValidationRejectsZeroAndNegativeValues() {
        XCTAssertNil(CurrencyConverter.positiveAmount("0"))
        XCTAssertNil(CurrencyConverter.positiveAmount("-10"))
        XCTAssertNil(CurrencyConverter.positiveAmount(""))
        XCTAssertEqual(CurrencyConverter.positiveAmount("0.00024"), Decimal(string: "0.00024"))
    }

    func testConvertsAssistCurrencyToHKD() throws {
        let hkd = try CurrencyConverter.convertToHKD(amount: Decimal(8500), rateToHKD: Decimal(string: "0.052")!)
        XCTAssertEqual(hkd, Decimal(442))
    }

    func testRejectsZeroRate() {
        XCTAssertThrowsError(try CurrencyConverter.convertToHKD(amount: Decimal(10), rateToHKD: Decimal(0)))
    }
}
