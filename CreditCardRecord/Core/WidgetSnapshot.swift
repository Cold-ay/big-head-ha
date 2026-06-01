import Foundation

struct WidgetDuePayment: Codable, Equatable {
    let cardName: String
    let amountHKD: Decimal
    let dueDate: Date
}

enum WidgetSnapshotBuilder {
    static func displayLine(for payment: WidgetDuePayment, now: Date, privateMode: Bool, calendar: Calendar = .current) -> String {
        let days = calendar.dateComponents([.day], from: calendar.startOfDay(for: now), to: calendar.startOfDay(for: payment.dueDate)).day ?? 0
        let amount = privateMode ? "" : " HK$\(payment.amountHKD)"
        return "\(payment.cardName)\(amount), due in \(max(days, 0)) day\(days == 1 ? "" : "s")"
    }
}
