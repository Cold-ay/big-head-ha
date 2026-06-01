import SwiftUI
import SwiftData

struct RepaymentView: View {
    @Query private var cards: [CreditCard]

    var body: some View {
        NavigationStack {
            List {
                Section("Next Payment Due") {
                    if cards.isEmpty {
                        Text("Add a card to start tracking repayment")
                    } else {
                        ForEach(cards) { card in
                            VStack(alignment: .leading, spacing: 4) {
                                Text(card.displayName).font(.headline)
                                Text("Statement day \(card.statementDay)")
                                Text("Due rule \(card.dueRuleKindRaw) \(card.dueDayOrOffset)")
                            }
                        }
                    }
                }
            }
            .navigationTitle("Repayment")
        }
    }
}
