import XCTest
@testable import CreditCardRecord

final class RepaymentCalculatorTests: XCTestCase {
    func testSumsTransactionsInsideCycleForCardOnly() {
        let calendar = Calendar(identifier: .gregorian)
        let cardID = UUID()
        let otherCardID = UUID()
        let cycle = RepaymentWindow(
            cardID: cardID,
            startDate: calendar.date(from: DateComponents(year: 2026, month: 6, day: 13))!,
            endDate: calendar.date(from: DateComponents(year: 2026, month: 7, day: 12))!
        )
        let transactions = [
            TransactionRecord(date: calendar.date(from: DateComponents(year: 2026, month: 6, day: 20))!, merchant: "Cafe", categoryName: "dining", cardID: cardID, hkdAmount: Decimal(58)),
            TransactionRecord(date: calendar.date(from: DateComponents(year: 2026, month: 7, day: 1))!, merchant: "MTR", categoryName: "transport", cardID: cardID, hkdAmount: Decimal(120)),
            TransactionRecord(date: calendar.date(from: DateComponents(year: 2026, month: 7, day: 1))!, merchant: "Shop", categoryName: "shopping", cardID: otherCardID, hkdAmount: Decimal(999))
        ]

        XCTAssertEqual(RepaymentCalculator.totalDue(for: cycle, transactions: transactions), Decimal(178))
    }
}
