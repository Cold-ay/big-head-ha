import Foundation

struct SpendingTotal: Identifiable, Equatable {
    let id: String
    let label: String
    let amount: Decimal
}

enum ConsumptionAnalytics {
    static func categoryTotals(from transactions: [TransactionRecord]) -> [SpendingTotal] {
        let totals = Dictionary(grouping: transactions, by: \.categoryName)
            .mapValues { records in
                records.reduce(Decimal(0)) { partial, record in
                    partial + record.hkdAmount
                }
            }

        return totals
            .map { SpendingTotal(id: $0.key, label: $0.key, amount: $0.value) }
            .sorted { lhs, rhs in
                if lhs.amount == rhs.amount {
                    return lhs.label.localizedCaseInsensitiveCompare(rhs.label) == .orderedAscending
                }
                return lhs.amount > rhs.amount
            }
    }

    static func monthlyTotals(from transactions: [TransactionRecord], calendar: Calendar = .current) -> [SpendingTotal] {
        let formatter = DateFormatter()
        formatter.calendar = calendar
        formatter.locale = Locale(identifier: "en_HK")
        formatter.dateFormat = "MMM yyyy"

        let totals = Dictionary(grouping: transactions) { record in
            calendar.date(from: calendar.dateComponents([.year, .month], from: record.date)) ?? record.date
        }
        .mapValues { records in
            records.reduce(Decimal(0)) { partial, record in
                partial + record.hkdAmount
            }
        }

        return totals
            .sorted { $0.key < $1.key }
            .map { date, amount in
                SpendingTotal(id: ISO8601DateFormatter().string(from: date), label: formatter.string(from: date), amount: amount)
            }
    }
}
