import SwiftUI
import Charts

struct ChartsView: View {
    @Environment(\.appStrings) private var strings
    @AppStorage("hideAmounts") private var hideAmounts = false
    let transactions: [TransactionRecord]
    let month: Date
    private var series: [SpendingTotal] {
        let calendar = Calendar.current
        let anchor = calendar.date(from: calendar.dateComponents([.year, .month], from: month)) ?? month
        return (-5...0).map { offset in
            let date = calendar.date(byAdding: .month, value: offset, to: anchor) ?? anchor
            let total = ConsumptionAnalytics.records(from: transactions, month: date).reduce(Decimal(0)) { $0 + $1.hkdAmount }
            return SpendingTotal(id: "\(offset)", label: strings.dateString(date, format: "MMM"), amount: total)
        }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text(strings.monthlyTrend).font(.system(size: 19, weight: .bold, design: .rounded))
                Spacer()
                Text("HKD").font(.caption).foregroundStyle(DashboardStyle.secondaryText)
            }
            if hideAmounts {
                Image(systemName: "eye.slash").font(.title2).frame(maxWidth: .infinity, minHeight: 150).foregroundStyle(DashboardStyle.secondaryText)
            } else if series.allSatisfy({ $0.amount == 0 }) {
                EmptySpendingState()
            } else {
                Chart(series) { item in
                    BarMark(x: .value("Month", item.label), y: .value("HKD", NSDecimalNumber(decimal: item.amount).doubleValue), width: .ratio(0.55))
                        .foregroundStyle(item.id == "0" ? DashboardStyle.secondary : DashboardStyle.primary.opacity(0.55))
                        .cornerRadius(5)
                }
                .chartXAxis { AxisMarks { _ in AxisValueLabel().font(.system(size: 11, weight: .medium)) } }
                .chartYAxis { AxisMarks(position: .leading) }
                .frame(height: 156)
                .accessibilityIdentifier("overview.trend")
            }
        }
    }
}
