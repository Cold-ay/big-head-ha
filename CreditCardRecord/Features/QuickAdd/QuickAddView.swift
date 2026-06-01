import SwiftData
import SwiftUI

struct QuickAddView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var cards: [CreditCard]
    @State private var amount = ""
    @State private var merchant = ""
    @State private var categoryName = "dining"
    @State private var selectedCardID: UUID?

    private let categories = ["dining", "transport", "grocery", "shopping", "bills", "entertainment", "travel", "online", "health", "education", "other"]

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    TabView(selection: $selectedCardID) {
                        ForEach(cards) { card in
                            VStack(alignment: .leading) {
                                Text(card.displayName).font(.headline)
                                Text("**** \(card.last4)").font(.subheadline)
                            }
                            .frame(maxWidth: .infinity, minHeight: 120)
                            .background(.thinMaterial)
                            .clipShape(RoundedRectangle(cornerRadius: 14))
                            .tag(Optional(card.id))
                        }
                    }
                    .frame(height: 150)
                    .tabViewStyle(.page)
                }

                Section("Transaction") {
                    TextField("Amount", text: $amount)
                        .keyboardType(.decimalPad)
                    TextField("Merchant", text: $merchant)
                    Picker("Category", selection: $categoryName) {
                        ForEach(categories, id: \.self) { Text($0).tag($0) }
                    }
                }

                Button("Save Transaction") {
                    saveTransaction()
                }
                .disabled(Decimal(string: amount) == nil || merchant.isEmpty)
            }
            .navigationTitle("Quick Add")
        }
    }

    private func saveTransaction() {
        guard let hkdAmount = Decimal(string: amount) else { return }
        let record = TransactionRecord(date: Date(), merchant: merchant, categoryName: categoryName, cardID: selectedCardID ?? cards.first?.id, hkdAmount: hkdAmount)
        modelContext.insert(record)
        amount = ""
        merchant = ""
    }
}
