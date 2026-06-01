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

    func testUsesInclusiveCalendarDaysAndPreservesFractionalAmounts() {
        let calendar = Calendar(identifier: .gregorian)
        let cardID = UUID()
        let cycle = RepaymentWindow(
            cardID: cardID,
            startDate: calendar.date(from: DateComponents(year: 2026, month: 6, day: 13))!,
            endDate: calendar.date(from: DateComponents(year: 2026, month: 7, day: 12))!
        )
        let transactions = [
            TransactionRecord(date: calendar.date(from: DateComponents(year: 2026, month: 6, day: 12, hour: 23, minute: 59))!, merchant: "Before", categoryName: "shopping", cardID: cardID, hkdAmount: Decimal(string: "100.10")!),
            TransactionRecord(date: calendar.date(from: DateComponents(year: 2026, month: 6, day: 13, hour: 15, minute: 30))!, merchant: "Start Day", categoryName: "dining", cardID: cardID, hkdAmount: Decimal(string: "10.25")!),
            TransactionRecord(date: calendar.date(from: DateComponents(year: 2026, month: 7, day: 12, hour: 16, minute: 45))!, merchant: "End Day", categoryName: "transport", cardID: cardID, hkdAmount: Decimal(string: "20.50")!),
            TransactionRecord(date: calendar.date(from: DateComponents(year: 2026, month: 7, day: 13))!, merchant: "After", categoryName: "shopping", cardID: cardID, hkdAmount: Decimal(string: "300.30")!),
            TransactionRecord(date: calendar.date(from: DateComponents(year: 2026, month: 6, day: 20))!, merchant: "Cash", categoryName: "cash", cardID: nil, hkdAmount: Decimal(string: "400.40")!)
        ]

        XCTAssertEqual(RepaymentCalculator.totalDue(for: cycle, transactions: transactions), Decimal(string: "30.75")!)
    }
}
