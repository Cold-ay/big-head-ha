import WidgetKit
import SwiftUI

struct PaymentEntry: TimelineEntry {
    let date: Date
    let line: String
}

struct Provider: TimelineProvider {
    func placeholder(in context: Context) -> PaymentEntry {
        PaymentEntry(date: Date(), line: "Next payment due")
    }

    func getSnapshot(in context: Context, completion: @escaping (PaymentEntry) -> Void) {
        completion(PaymentEntry(date: Date(), line: "HSBC Visa, due in 5 days"))
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<PaymentEntry>) -> Void) {
        let entry = PaymentEntry(date: Date(), line: "Open app to refresh payments")
        completion(Timeline(entries: [entry], policy: .after(Date().addingTimeInterval(3600))))
    }
}

struct CreditCardRecordWidgetEntryView: View {
    var entry: Provider.Entry

    var body: some View {
        VStack(alignment: .leading) {
            Text("Next Payment")
                .font(.caption)
            Text(entry.line)
                .font(.headline)
                .minimumScaleFactor(0.75)
        }
        .containerBackground(.background, for: .widget)
    }
}

@main
struct CreditCardRecordWidget: Widget {
    let kind = "CreditCardRecordWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: Provider()) { entry in
            CreditCardRecordWidgetEntryView(entry: entry)
        }
        .configurationDisplayName("BigHeadHa: Next Payment")
        .description("Shows the next credit card payment countdown.")
        .supportedFamilies([.systemSmall, .systemMedium])
    }
}
