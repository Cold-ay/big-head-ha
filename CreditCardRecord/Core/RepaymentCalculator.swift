import Foundation

struct RepaymentWindow {
    let cardID: UUID
    let startDate: Date
    let endDate: Date
}

enum RepaymentCalculator {
    static func totalDue(for window: RepaymentWindow, transactions: [TransactionRecord]) -> Decimal {
        transactions
            .filter { $0.cardID == window.cardID && $0.date >= window.startDate && $0.date <= window.endDate }
            .reduce(Decimal(0)) { $0 + $1.hkdAmount }
    }
}
