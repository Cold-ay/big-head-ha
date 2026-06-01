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
    private var selectedCardIDForSave: UUID? {
        selectedCardID ?? cards.first?.id
    }

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    Group {
                        if cards.isEmpty {
                            Text("Add a card to start quick recording")
                                .foregroundStyle(.secondary)
                                .frame(maxWidth: .infinity, minHeight: 120)
                        } else {
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
                            .tabViewStyle(.page)
                        }
                    }
                    .frame(height: 150)
                }

                Section("Transaction") {
                    TextField("Amount", text: $amount)
                        .keyboardType(.decimalPad)
                        .accessibilityIdentifier("quickAdd.amount")
                    TextField("Merchant", text: $merchant)
                        .accessibilityIdentifier("quickAdd.merchant")
                    Picker("Category", selection: $categoryName) {
                        ForEach(categories, id: \.self) { Text($0).tag($0) }
                    }
                }

                Button("Save Transaction") {
                    saveTransaction()
                }
                .accessibilityIdentifier("quickAdd.save")
                .disabled(Decimal(string: amount) == nil || merchant.isEmpty || selectedCardIDForSave == nil)
            }
            .navigationTitle("Quick Add")
        }
    }

    private func saveTransaction() {
        guard let hkdAmount = Decimal(string: amount), let cardID = selectedCardIDForSave else { return }
        let record = TransactionRecord(date: Date(), merchant: merchant, categoryName: categoryName, cardID: cardID, hkdAmount: hkdAmount)
        modelContext.insert(record)
        amount = ""
        merchant = ""
    }
}
