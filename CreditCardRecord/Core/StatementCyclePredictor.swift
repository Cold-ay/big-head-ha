import Foundation

struct PredictedCycle: Equatable {
    let startDate: Date
    let endDate: Date
    let statementDate: Date
    let dueDate: Date
}

enum StatementCyclePredictor {
    static func predictNextCycle(previousStatementDate: Date, statementDay: Int, dueRuleKind: DueRuleKind, dueDayOrOffset: Int, calendar: Calendar = .current) -> PredictedCycle {
        let nextStatement = dateBySetting(day: statementDay, monthsAfter: 1, from: previousStatementDate, calendar: calendar)
        let startDate = calendar.date(byAdding: .day, value: 1, to: previousStatementDate)!
        let endDate = nextStatement

        let dueDate: Date
        switch dueRuleKind {
        case .fixedDayOfMonth:
            dueDate = dateBySetting(day: dueDayOrOffset, monthsAfter: 1, from: nextStatement, calendar: calendar)
        case .daysAfterStatement:
            dueDate = calendar.date(byAdding: .day, value: dueDayOrOffset, to: nextStatement)!
        }

        return PredictedCycle(startDate: startDate, endDate: endDate, statementDate: nextStatement, dueDate: dueDate)
    }

    private static func dateBySetting(day: Int, monthsAfter: Int, from date: Date, calendar: Calendar) -> Date {
        let shifted = calendar.date(byAdding: .month, value: monthsAfter, to: date)!
        var components = calendar.dateComponents([.year, .month], from: shifted)
        let range = calendar.range(of: .day, in: .month, for: shifted)!
        components.day = min(max(day, 1), range.count)
        return calendar.date(from: components)!
    }
}
