import Foundation

struct RepaymentWindow {
    let cardID: UUID
    let startDate: Date
    let endDate: Date
    let calendar: Calendar = Calendar(identifier: .gregorian)
}

enum RepaymentCalculator {
    static func totalDue(for window: RepaymentWindow, transactions: [TransactionRecord]) -> Decimal {
        let startOfCycle = window.calendar.startOfDay(for: window.startDate)
        let endOfCycle = window.calendar.date(byAdding: .day, value: 1, to: window.calendar.startOfDay(for: window.endDate))!

        return transactions
            .filter { $0.cardID == window.cardID && $0.date >= startOfCycle && $0.date < endOfCycle }
            .reduce(Decimal(0)) { $0 + $1.hkdAmount }
    }
}
