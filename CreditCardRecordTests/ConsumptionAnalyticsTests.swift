import XCTest
@testable import CreditCardRecord

final class ConsumptionAnalyticsTests: XCTestCase {
    func testMonthAndCardSelectionExcludeOtherCardsAndFutureSpending() {
        let calendar = Calendar(identifier: .gregorian)
        let month = calendar.date(from: DateComponents(year: 2026, month: 11, day: 18))!
        let card = UUID()
        let records = [
            TransactionRecord(date: month, merchant: "Lunch", categoryName: "dining", cardID: card, hkdAmount: 80),
            TransactionRecord(date: month, merchant: "Train", categoryName: "transport", cardID: UUID(), hkdAmount: 20),
            TransactionRecord(date: calendar.date(byAdding: .day, value: 1, to: month)!, merchant: "Future", categoryName: "other", cardID: card, hkdAmount: 999)
        ]
        XCTAssertEqual(ConsumptionAnalytics.records(from: records, month: month, calendar: calendar, now: month).count, 2)
        XCTAssertEqual(ConsumptionAnalytics.records(from: records, cardID: card, month: month, calendar: calendar, now: month).map(\.merchant), ["Lunch"])
    }

    func testDefaultCardFallsBackWhenRemovedOrInactive() {
        let card = CreditCard(bankName: "Bank", displayName: "First", last4: "1234", statementDay: 15, dueRuleKind: .daysAfterStatement, dueDayOrOffset: 25)
        XCTAssertEqual(ConsumptionAnalytics.resolvedCardID(preferred: UUID().uuidString, cards: [card]), card.id)
        card.isActive = false
        XCTAssertNil(ConsumptionAnalytics.resolvedCardID(preferred: card.id.uuidString, cards: [card]))
    }

    func testEveryCategoryHasUniqueIconAndFourTabsHaveDistinctRoles() {
        XCTAssertEqual(SpendingCategoryOption.allCases.count, 11)
        XCTAssertEqual(Set(SpendingCategoryOption.allCases.map(\.symbolName)).count, 11)
        XCTAssertEqual(SpendingCategoryOption.resolve("unknown"), .other)
        XCTAssertEqual(AppTab.allCases.map(\.rawValue), ["overview", "quickAdd", "cards", "repayment"])
    }

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
