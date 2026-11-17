import Foundation

struct PredictedCycle: Equatable {
    let startDate: Date
    let endDate: Date
    let statementDate: Date
    let dueDate: Date
}

enum StatementCyclePredictor {
    static func upcomingCycle(for card: CreditCard, cycles: [StatementCycle] = [], today: Date = Date(), calendar: Calendar = Calendar(identifier: .gregorian)) -> PredictedCycle {
        let recorded = cycles.filter { $0.cardID == card.id }
        if let unpaid = recorded.filter({ !$0.isPaid }).min(by: { $0.dueDate < $1.dueDate }) {
            return PredictedCycle(startDate: unpaid.startDate, endDate: unpaid.endDate,
                                  statementDate: unpaid.statementDate, dueDate: unpaid.dueDate)
        }
        let day = calendar.startOfDay(for: today)
        let month = calendar.date(from: calendar.dateComponents([.year, .month], from: day))!
        // Include earlier statements whose payment deadline has not passed yet.
        let candidates = (-3...2).map { offset -> PredictedCycle in
            let previousMonth = calendar.date(byAdding: .month, value: offset - 1, to: month)!
            let previousStatement = dateBySetting(day: card.statementDay, monthsAfter: 0, from: previousMonth, calendar: calendar)
            return predictNextCycle(previousStatementDate: previousStatement, statementDay: card.statementDay,
                                    dueRuleKind: card.dueRuleKind, dueDayOrOffset: card.dueDayOrOffset, calendar: calendar)
        }
        return candidates.filter { candidate in
            candidate.dueDate >= day && !recorded.contains { calendar.isDate($0.statementDate, inSameDayAs: candidate.statementDate) }
        }.min(by: { $0.dueDate < $1.dueDate }) ?? candidates.last!
    }

    static func predictNextCycle(previousStatementDate: Date, statementDay: Int, dueRuleKind: DueRuleKind, dueDayOrOffset: Int, calendar: Calendar = Calendar(identifier: .gregorian)) -> PredictedCycle {
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
