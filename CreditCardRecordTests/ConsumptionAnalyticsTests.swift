import XCTest
@testable import CreditCardRecord

final class ConsumptionAnalyticsTests: XCTestCase {
    func testCategoryTotalsSortByHighestSpend() {
        let records = [
            TransactionRecord(date: Date(timeIntervalSince1970: 0), merchant: "Cafe", categoryName: "dining", cardID: nil, hkdAmount: Decimal(88)),
            TransactionRecord(date: Date(timeIntervalSince1970: 0), merchant: "MTR", categoryName: "transport", cardID: nil, hkdAmount: Decimal(12)),
            TransactionRecord(date: Date(timeIntervalSince1970: 0), merchant: "Lunch", categoryName: "dining", cardID: nil, hkdAmount: Decimal(52))
        ]

        let totals = ConsumptionAnalytics.categoryTotals(from: records)

        XCTAssertEqual(totals.first, SpendingTotal(id: "dining", label: "dining", amount: Decimal(140)))
        XCTAssertEqual(totals.last, SpendingTotal(id: "transport", label: "transport", amount: Decimal(12)))
    }

    func testMonthlyTotalsSortChronologically() {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone(secondsFromGMT: 0)!
        let records = [
            TransactionRecord(date: calendar.date(from: DateComponents(year: 2026, month: 2, day: 1))!, merchant: "Cafe", categoryName: "dining", cardID: nil, hkdAmount: Decimal(80)),
            TransactionRecord(date: calendar.date(from: DateComponents(year: 2026, month: 1, day: 3))!, merchant: "MTR", categoryName: "transport", cardID: nil, hkdAmount: Decimal(20)),
            TransactionRecord(date: calendar.date(from: DateComponents(year: 2026, month: 1, day: 10))!, merchant: "Lunch", categoryName: "dining", cardID: nil, hkdAmount: Decimal(30))
        ]

        let totals = ConsumptionAnalytics.monthlyTotals(from: records, calendar: calendar)

        XCTAssertEqual(totals.map(\.amount), [Decimal(50), Decimal(80)])
        XCTAssertEqual(totals.map(\.label), ["Jan 2026", "Feb 2026"])
    }
}
