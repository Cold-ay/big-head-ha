import Foundation

enum RecurringDeductionGenerator {
    static func transactionsToCreate(for rule: RecurringDeduction, existingTransactions: [TransactionRecord], today: Date = Date(), calendar: Calendar = .current) -> [TransactionRecord] {
        guard rule.isActive, rule.hkdAmount > 0, !rule.merchant.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return [] }

        let today = calendar.startOfDay(for: today)
        let startDate = calendar.startOfDay(for: rule.startDate)
        let endDate = rule.endDate.map { calendar.startOfDay(for: $0) }
        let finalDate = min(today, endDate ?? today)
        guard finalDate >= startDate else { return [] }

        let existingMonths = Set(
            existingTransactions.compactMap { transaction -> String? in
                guard transaction.recurringDeductionID == rule.id else { return nil }
                return transaction.recurringYearMonth
            }
        )

        var transactions = [TransactionRecord]()
        var monthCursor = calendar.date(from: calendar.dateComponents([.year, .month], from: startDate)) ?? startDate
        let finalMonth = calendar.date(from: calendar.dateComponents([.year, .month], from: finalDate)) ?? finalDate

        while monthCursor <= finalMonth {
            let dueDate = dueDate(for: monthCursor, monthlyDay: rule.monthlyDay, calendar: calendar)
            let yearMonth = yearMonthKey(for: monthCursor, calendar: calendar)

            if dueDate >= startDate,
               dueDate <= finalDate,
               !existingMonths.contains(yearMonth) {
                transactions.append(
                    TransactionRecord(
                        date: dueDate,
                        merchant: rule.merchant,
                        categoryName: rule.categoryName,
                        cardID: rule.cardID,
                        hkdAmount: rule.hkdAmount,
                        note: "Monthly deduction",
                        recurringDeductionID: rule.id,
                        recurringYearMonth: yearMonth
                    )
                )
            }

            guard let nextMonth = calendar.date(byAdding: .month, value: 1, to: monthCursor) else { break }
            monthCursor = nextMonth
        }

        return transactions
    }

    static func yearMonthKey(for date: Date, calendar: Calendar = .current) -> String {
        let components = calendar.dateComponents([.year, .month], from: date)
        return String(format: "%04d-%02d", components.year ?? 0, components.month ?? 0)
    }

    static func yearMonthDayKey(for date: Date, calendar: Calendar = .current) -> String {
        let components = calendar.dateComponents([.year, .month, .day], from: date)
        return String(format: "%04d-%02d-%02d", components.year ?? 0, components.month ?? 0, components.day ?? 0)
    }

    private static func dueDate(for monthDate: Date, monthlyDay: Int, calendar: Calendar) -> Date {
        var components = calendar.dateComponents([.year, .month], from: monthDate)
        let daysInMonth = calendar.range(of: .day, in: .month, for: monthDate)?.count ?? monthlyDay
        components.day = min(max(monthlyDay, 1), daysInMonth)
        return calendar.date(from: components) ?? monthDate
    }
}
