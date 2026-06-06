import SwiftData
import SwiftUI

struct CardsView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \CreditCard.displayName) private var cards: [CreditCard]

    @State private var selectedPresetID = HongKongCardCatalog.presets.first?.id ?? ""
    @State private var customDisplayName = ""
    @State private var customBankName = ""
    @State private var last4 = ""
    @State private var statementDay = 15
    @State private var dueOffsetDays = 25

    private var selectedPreset: HongKongCardPreset? {
        HongKongCardCatalog.presets.first { $0.id == selectedPresetID }
    }

    var body: some View {
        NavigationStack {
            Form {
                Section("Active Cards") {
                    if cards.isEmpty {
                        Text("No cards added")
                            .foregroundStyle(.secondary)
                    } else {
                        ForEach(cards) { card in
                            VStack(alignment: .leading, spacing: 4) {
                                Text(card.displayName)
                                    .font(.headline)
                                Text("\(card.bankName) • **** \(card.last4)")
                                    .font(.subheadline)
                                    .foregroundStyle(.secondary)
                                Text("Statement day \(card.statementDay), due \(card.dueDayOrOffset) days after statement")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                        }
                    }
                }

                Section("Hong Kong Presets") {
                    Picker("Issuer/Card", selection: $selectedPresetID) {
                        ForEach(HongKongCardCatalog.presets) { preset in
                            Text(preset.displayName).tag(preset.id)
                        }
                    }

                    TextField("Last 4 digits", text: $last4)
                        .keyboardType(.numberPad)
                        .onChange(of: last4) { _, newValue in
                            last4 = String(newValue.filter(\.isNumber).prefix(4))
                        }

                    Button("Add Preset Card") {
                        addPresetCard()
                    }
                    .disabled(selectedPreset == nil || last4.count != 4)
                }

                Section("Manual Card") {
                    TextField("Bank / issuer", text: $customBankName)
                    TextField("Card name", text: $customDisplayName)

                    Stepper("Statement day: \(statementDay)", value: $statementDay, in: 1...31)
                    Stepper("Due offset: \(dueOffsetDays) days", value: $dueOffsetDays, in: 1...60)

                    Button("Add Manual Card") {
                        addManualCard()
                    }
                    .disabled(customBankName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || customDisplayName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || last4.count != 4)
                }
            }
            .navigationTitle("Cards")
        }
    }

    private func addPresetCard() {
        guard let selectedPreset else { return }
        let card = CreditCard(
            bankName: selectedPreset.issuerName,
            displayName: selectedPreset.displayName,
            last4: last4,
            statementDay: selectedPreset.defaultStatementDay,
            dueRuleKind: .daysAfterStatement,
            dueDayOrOffset: selectedPreset.defaultDueOffsetDays
        )
        modelContext.insert(card)
        last4 = ""
    }

    private func addManualCard() {
        let bankName = customBankName.trimmingCharacters(in: .whitespacesAndNewlines)
        let displayName = customDisplayName.trimmingCharacters(in: .whitespacesAndNewlines)
        let card = CreditCard(
            bankName: bankName,
            displayName: displayName,
            last4: last4,
            statementDay: statementDay,
            dueRuleKind: .daysAfterStatement,
            dueDayOrOffset: dueOffsetDays
        )
        modelContext.insert(card)
        customBankName = ""
        customDisplayName = ""
        last4 = ""
    }
}
