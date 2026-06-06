import Charts
import SwiftData
import SwiftUI

struct ChartsView: View {
    @Query(sort: \TransactionRecord.date, order: .reverse) private var transactions: [TransactionRecord]

    private var categoryTotals: [SpendingTotal] {
        ConsumptionAnalytics.categoryTotals(from: transactions)
    }

    private var monthlyTotals: [SpendingTotal] {
        ConsumptionAnalytics.monthlyTotals(from: transactions)
    }

    var body: some View {
        NavigationStack {
            List {
                if transactions.isEmpty {
                    ContentUnavailableView("No spending yet", systemImage: "chart.pie", description: Text("Quick records will appear here as category and time charts."))
                } else {
                    Section("By Category") {
                        Chart(categoryTotals) { total in
                            BarMark(
                                x: .value("Amount", total.amount.doubleValue),
                                y: .value("Category", total.label)
                            )
                        }
                        .frame(height: max(220, CGFloat(categoryTotals.count) * 36))
                    }

                    Section("By Month") {
                        Chart(monthlyTotals) { total in
                            LineMark(
                                x: .value("Month", total.label),
                                y: .value("Amount", total.amount.doubleValue)
                            )
                            PointMark(
                                x: .value("Month", total.label),
                                y: .value("Amount", total.amount.doubleValue)
                            )
                        }
                        .frame(height: 240)
                    }

                    Section("Habit Summary") {
                        if let largestCategory = categoryTotals.first {
                            LabeledContent("Top category", value: largestCategory.label)
                            LabeledContent("Top category spend", value: CurrencyFormatter.hkdString(from: largestCategory.amount))
                        }
                        LabeledContent("Recorded transactions", value: "\(transactions.count)")
                    }
                }
            }
            .navigationTitle("Charts")
        }
    }
}

private extension Decimal {
    var doubleValue: Double {
        NSDecimalNumber(decimal: self).doubleValue
    }
}

private enum CurrencyFormatter {
    static func hkdString(from amount: Decimal) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = "HKD"
        formatter.currencySymbol = "HK$"
        formatter.locale = Locale(identifier: "en_HK")
        return formatter.string(from: NSDecimalNumber(decimal: amount)) ?? "HK$0.00"
    }
}
