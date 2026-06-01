import XCTest
@testable import CreditCardRecord

final class WidgetSnapshotTests: XCTestCase {
    private let calendar = Calendar(identifier: .gregorian)

    func testPrivateSnapshotShowsExactTomorrowTextWithoutAmount() {
        let due = WidgetDuePayment(cardName: "HSBC Visa", amountHKD: Decimal(3280), dueDate: date(year: 2026, month: 6, day: 2))
        let snapshot = WidgetSnapshotBuilder.displayLine(for: due, now: date(year: 2026, month: 6, day: 1), privateMode: true)

        XCTAssertEqual(snapshot, "HSBC Visa, due in 1 day")
    }

    func testPublicSnapshotFormatsHKDWithGroupingAndTwoDecimals() {
        let due = WidgetDuePayment(cardName: "HSBC Visa", amountHKD: Decimal(string: "3280.5")!, dueDate: date(year: 2026, month: 6, day: 3))
        let snapshot = WidgetSnapshotBuilder.displayLine(for: due, now: date(year: 2026, month: 6, day: 1), privateMode: false)

        XCTAssertEqual(snapshot, "HSBC Visa HK$3,280.50, due in 2 days")
    }

    func testSnapshotShowsDueToday() {
        let due = WidgetDuePayment(cardName: "HSBC Visa", amountHKD: Decimal(3280), dueDate: date(year: 2026, month: 6, day: 1))
        let snapshot = WidgetSnapshotBuilder.displayLine(for: due, now: date(year: 2026, month: 6, day: 1), privateMode: true)

        XCTAssertEqual(snapshot, "HSBC Visa, due today")
    }

    func testSnapshotShowsSingularOverdueDay() {
        let due = WidgetDuePayment(cardName: "HSBC Visa", amountHKD: Decimal(3280), dueDate: date(year: 2026, month: 5, day: 31))
        let snapshot = WidgetSnapshotBuilder.displayLine(for: due, now: date(year: 2026, month: 6, day: 1), privateMode: true)

        XCTAssertEqual(snapshot, "HSBC Visa, 1 day overdue")
    }

    func testSnapshotShowsPluralOverdueDays() {
        let due = WidgetDuePayment(cardName: "HSBC Visa", amountHKD: Decimal(3280), dueDate: date(year: 2026, month: 5, day: 30))
        let snapshot = WidgetSnapshotBuilder.displayLine(for: due, now: date(year: 2026, month: 6, day: 1), privateMode: true)

        XCTAssertEqual(snapshot, "HSBC Visa, 2 days overdue")
    }

    func testSnapshotShowsPluralFutureDays() {
        let due = WidgetDuePayment(cardName: "HSBC Visa", amountHKD: Decimal(3280), dueDate: date(year: 2026, month: 6, day: 4))
        let snapshot = WidgetSnapshotBuilder.displayLine(for: due, now: date(year: 2026, month: 6, day: 1), privateMode: true)

        XCTAssertEqual(snapshot, "HSBC Visa, due in 3 days")
    }

    private func date(year: Int, month: Int, day: Int) -> Date {
        calendar.date(from: DateComponents(year: year, month: month, day: day))!
    }
}
