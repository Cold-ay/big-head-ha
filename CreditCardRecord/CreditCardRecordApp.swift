import SwiftData
import SwiftUI

@main
struct CreditCardRecordApp: App {
    private var isUITesting: Bool {
        ProcessInfo.processInfo.arguments.contains("--uitesting")
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(for: [CreditCard.self, TransactionRecord.self, StatementCycle.self, SpendingCategory.self], inMemory: isUITesting)
    }
}
