import SwiftData
import SwiftUI

@main
struct CreditCardRecordApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(for: [CreditCard.self, TransactionRecord.self, StatementCycle.self, SpendingCategory.self])
    }
}
