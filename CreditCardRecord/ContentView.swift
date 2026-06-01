import SwiftData
import SwiftUI

struct ContentView: View {
    var body: some View {
        TabView {
            QuickAddView()
                .tabItem { Label("Quick", systemImage: "plus.circle") }
            RepaymentView()
                .tabItem { Label("Repayment", systemImage: "creditcard") }
            Text("Charts")
                .tabItem { Label("Charts", systemImage: "chart.pie") }
            Text("Cards")
                .tabItem { Label("Cards", systemImage: "rectangle.stack") }
            Text("Settings")
                .tabItem { Label("Settings", systemImage: "gearshape") }
        }
    }
}

#Preview {
    ContentView()
        .modelContainer(for: [CreditCard.self, TransactionRecord.self, StatementCycle.self, SpendingCategory.self] as [any PersistentModel.Type], inMemory: true)
}
