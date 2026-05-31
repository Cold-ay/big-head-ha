import XCTest
@testable import CreditCardRecord

final class ModelTests: XCTestCase {
    func testTransactionKeepsOriginalCurrencyAndHKD() {
        let transaction = TransactionRecord(
            date: Date(timeIntervalSince1970: 0),
            merchant: "Amazon JP",
            categoryName: "online",
            cardID: UUID(),
            hkdAmount: Decimal(442),
            originalAmount: Decimal(8500),
            originalCurrencyCode: "JPY",
            exchangeRateToHKD: Decimal(string: "0.052")!,
            note: "travel adapter"
        )

        XCTAssertEqual(transaction.originalCurrencyCode, "JPY")
        XCTAssertEqual(transaction.hkdAmount, Decimal(442))
    }
}
