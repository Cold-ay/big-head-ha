import XCTest
@testable import CreditCardRecord

final class StatementCyclePredictorTests: XCTestCase {
    func testUpcomingDueIncludesPreviousMonthsStatement() {
        let calendar = Calendar(identifier: .gregorian)
        let card = CreditCard(bankName: "HSBC", displayName: "Red", last4: "1234", statementDay: 15,
                              dueRuleKind: .daysAfterStatement, dueDayOrOffset: 25)
        let cycle = StatementCyclePredictor.upcomingCycle(for: card, today: date(year: 2026, month: 11, day: 17, calendar: calendar), calendar: calendar)
        XCTAssertEqual(cycle.statementDate, date(year: 2026, month: 11, day: 15, calendar: calendar))
        XCTAssertEqual(cycle.dueDate, date(year: 2026, month: 12, day: 10, calendar: calendar))
        let earlier = StatementCyclePredictor.upcomingCycle(for: card, today: date(year: 2026, month: 11, day: 2, calendar: calendar), calendar: calendar)
        XCTAssertEqual(earlier.dueDate, date(year: 2026, month: 11, day: 9, calendar: calendar))
    }

    func testManualDueDateAndPaidStatusAreRespected() {
        let calendar = Calendar(identifier: .gregorian)
        let card = CreditCard(bankName: "Bank", displayName: "Card", last4: "1234", statementDay: 15,
                              dueRuleKind: .daysAfterStatement, dueDayOrOffset: 25)
        let recorded = StatementCycle(cardID: card.id,
                                      startDate: date(year: 2026, month: 10, day: 16, calendar: calendar),
                                      endDate: date(year: 2026, month: 11, day: 15, calendar: calendar),
                                      statementDate: date(year: 2026, month: 11, day: 15, calendar: calendar),
                                      dueDate: date(year: 2026, month: 12, day: 12, calendar: calendar), isManualDate: true)
        let today = date(year: 2026, month: 11, day: 17, calendar: calendar)
        XCTAssertEqual(StatementCyclePredictor.upcomingCycle(for: card, cycles: [recorded], today: today, calendar: calendar).dueDate, recorded.dueDate)
        recorded.isPaid = true
        XCTAssertEqual(StatementCyclePredictor.upcomingCycle(for: card, cycles: [recorded], today: today, calendar: calendar).statementDate,
                       date(year: 2026, month: 12, day: 15, calendar: calendar))
    }

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
