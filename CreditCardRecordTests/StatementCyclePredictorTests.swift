import XCTest
@testable import CreditCardRecord

final class StatementCyclePredictorTests: XCTestCase {
    func testPredictsFixedDueDayNextMonth() throws {
        let calendar = Calendar(identifier: .gregorian)
        let firstStatement = calendar.date(from: DateComponents(year: 2026, month: 6, day: 12))!
        let cycle = StatementCyclePredictor.predictNextCycle(
            previousStatementDate: firstStatement,
            statementDay: 12,
            dueRuleKind: .fixedDayOfMonth,
            dueDayOrOffset: 5,
            calendar: calendar
        )

        XCTAssertEqual(cycle.startDate, date(year: 2026, month: 6, day: 13, calendar: calendar))
        XCTAssertEqual(cycle.endDate, date(year: 2026, month: 7, day: 12, calendar: calendar))
        XCTAssertEqual(cycle.statementDate, date(year: 2026, month: 7, day: 12, calendar: calendar))
        XCTAssertEqual(cycle.dueDate, date(year: 2026, month: 8, day: 5, calendar: calendar))
    }

    func testPredictsOffsetDueDate() {
        let calendar = Calendar(identifier: .gregorian)
        let firstStatement = calendar.date(from: DateComponents(year: 2026, month: 6, day: 12))!
        let cycle = StatementCyclePredictor.predictNextCycle(
            previousStatementDate: firstStatement,
            statementDay: 12,
            dueRuleKind: .daysAfterStatement,
            dueDayOrOffset: 25,
            calendar: calendar
        )

        XCTAssertEqual(cycle.startDate, date(year: 2026, month: 6, day: 13, calendar: calendar))
        XCTAssertEqual(cycle.endDate, date(year: 2026, month: 7, day: 12, calendar: calendar))
        XCTAssertEqual(cycle.statementDate, date(year: 2026, month: 7, day: 12, calendar: calendar))
        XCTAssertEqual(cycle.dueDate, date(year: 2026, month: 8, day: 6, calendar: calendar))
    }

    func testClampsStatementDayAtMonthBoundary() {
        let calendar = Calendar(identifier: .gregorian)
        let firstStatement = date(year: 2026, month: 1, day: 31, calendar: calendar)
        let cycle = StatementCyclePredictor.predictNextCycle(
            previousStatementDate: firstStatement,
            statementDay: 31,
            dueRuleKind: .fixedDayOfMonth,
            dueDayOrOffset: 31,
            calendar: calendar
        )

        XCTAssertEqual(cycle.startDate, date(year: 2026, month: 2, day: 1, calendar: calendar))
        XCTAssertEqual(cycle.endDate, date(year: 2026, month: 2, day: 28, calendar: calendar))
        XCTAssertEqual(cycle.statementDate, date(year: 2026, month: 2, day: 28, calendar: calendar))
        XCTAssertEqual(cycle.dueDate, date(year: 2026, month: 3, day: 31, calendar: calendar))
    }

    func testDefaultCalendarUsesGregorianCycle() {
        let calendar = Calendar(identifier: .gregorian)
        let firstStatement = date(year: 2026, month: 1, day: 31, calendar: calendar)
        let cycle = StatementCyclePredictor.predictNextCycle(
            previousStatementDate: firstStatement,
            statementDay: 31,
            dueRuleKind: .fixedDayOfMonth,
            dueDayOrOffset: 31
        )

        XCTAssertEqual(cycle.startDate, date(year: 2026, month: 2, day: 1, calendar: calendar))
        XCTAssertEqual(cycle.endDate, date(year: 2026, month: 2, day: 28, calendar: calendar))
        XCTAssertEqual(cycle.statementDate, date(year: 2026, month: 2, day: 28, calendar: calendar))
        XCTAssertEqual(cycle.dueDate, date(year: 2026, month: 3, day: 31, calendar: calendar))
    }

    private func date(year: Int, month: Int, day: Int, calendar: Calendar) -> Date {
        calendar.date(from: DateComponents(year: year, month: month, day: day))!
    }
}
