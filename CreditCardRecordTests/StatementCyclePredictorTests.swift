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

        XCTAssertEqual(calendar.component(.day, from: cycle.statementDate), 12)
        XCTAssertEqual(calendar.component(.month, from: cycle.statementDate), 7)
        XCTAssertEqual(calendar.component(.day, from: cycle.dueDate), 5)
        XCTAssertEqual(calendar.component(.month, from: cycle.dueDate), 8)
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

        XCTAssertEqual(calendar.component(.day, from: cycle.dueDate), 7)
        XCTAssertEqual(calendar.component(.month, from: cycle.dueDate), 7)
    }
}
