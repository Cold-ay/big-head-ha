import Foundation

struct WidgetDuePayment: Codable, Equatable {
    let cardName: String
    let amountHKD: Decimal
    let dueDate: Date
}

enum WidgetSnapshotBuilder {
    static func displayLine(for payment: WidgetDuePayment, now: Date, privateMode: Bool, calendar: Calendar = Calendar(identifier: .gregorian)) -> String {
        let days = calendar.dateComponents([.day], from: calendar.startOfDay(for: now), to: calendar.startOfDay(for: payment.dueDate)).day ?? 0
        let amount = privateMode ? "" : " \(formattedHKD(payment.amountHKD))"
        return "\(payment.cardName)\(amount), \(countdownText(for: days))"
    }

    private static func formattedHKD(_ amount: Decimal) -> String {
        let formatter = NumberFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.numberStyle = .decimal
        formatter.minimumFractionDigits = 2
        formatter.maximumFractionDigits = 2
        formatter.usesGroupingSeparator = true
        return "HK$\(formatter.string(from: amount as NSDecimalNumber) ?? "0.00")"
    }

    private static func countdownText(for days: Int) -> String {
        if days < 0 {
            let overdueDays = abs(days)
            return "\(overdueDays) day\(overdueDays == 1 ? "" : "s") overdue"
        }

        if days == 0 {
            return "due today"
        }

        return "due in \(days) day\(days == 1 ? "" : "s")"
    }
}
