import SwiftData
import SwiftUI

struct CardsView: View {
    @Environment(\.appStrings) private var strings
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \CreditCard.displayName) private var cards: [CreditCard]
    @Query private var transactions: [TransactionRecord]
    @Query private var cycles: [StatementCycle]
    @Query private var rules: [RecurringDeduction]
    @State private var selectedCardID: UUID?
    @State private var month = Date()
    @State private var pendingRemoval: CreditCard?
    var onAddCard: () -> Void = {}
    var onSettings: () -> Void = {}
    private var selected: CreditCard? { cards.first { $0.id == selectedCardID } ?? cards.first }
    private var records: [TransactionRecord] {
        guard let selected else { return [] }
        return ConsumptionAnalytics.records(from: transactions, cardID: selected.id, month: month)
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    if cards.isEmpty {
                        AddCardEmptyState(action: onAddCard)
                    } else {
                        MonthSelector(month: $month)
                        CardCarousel(cards: cards, transactions: transactions, selection: $selectedCardID, month: month)
                        if let selected {
                            HStack {
                                Label(strings.cardKind(selected.paymentKind), systemImage: selected.requiresRepayment ? "calendar" : "wallet.pass")
                                    .font(.subheadline).foregroundStyle(DashboardStyle.secondaryText)
                                Spacer()
                                Button(role: .destructive) { pendingRemoval = selected } label: {
                                    Image(systemName: "trash").frame(width: 44, height: 44)
                                }
                                .accessibilityLabel(strings.removeCard).accessibilityIdentifier("cards.remove.\(selected.id)").help(strings.removeCard)
                            }
                        }
                        Divider()
                        SpendingBreakdown(records: records)
                        Divider()
                        TransactionList(records: records, cards: cards)
                    }
                }.padding(.horizontal, 20).padding(.top, 12).padding(.bottom, 32)
            }
            .background(DashboardBackground().ignoresSafeArea())
            .navigationTitle(strings.cardsTitle).navigationBarTitleDisplayMode(.inline)
            .toolbar { ScreenActions(onAddCard: onAddCard, onSettings: onSettings) }
            .alert(strings.removeCard, isPresented: Binding(get: { pendingRemoval != nil }, set: { if !$0 { pendingRemoval = nil } })) {
                Button(strings.cancel, role: .cancel) { pendingRemoval = nil }
                Button(strings.remove, role: .destructive) { removeCard() }
            } message: {
                if let card = pendingRemoval {
                    Text(CardRemovalSummary.confirmationMessage(for: card, in: transactions, statementCycles: cycles, language: strings.language))
                }
            }
        }
    }
    private func removeCard() {
        guard let card = pendingRemoval else { return }
        cycles.filter { $0.cardID == card.id }.forEach(modelContext.delete)
        rules.filter { $0.cardID == card.id }.forEach(modelContext.delete)
        modelContext.delete(card)
        selectedCardID = cards.first { $0.id != card.id }?.id
        pendingRemoval = nil
    }
}

struct AddCardView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var entryMode = 0
    @Environment(\.appStrings) private var strings
    @Environment(\.modelContext) private var modelContext

    @State private var selectedMarket = CardMarket.hongKong
    @State private var selectedIssuerName = HongKongCardCatalog.issuerNames.first ?? ""
    @State private var selectedPresetID = HongKongCardCatalog.presets.first?.id ?? ""
    @State private var customDisplayName = ""
    @State private var customBankName = ""
    @State private var last4 = ""
    @State private var firstStatementDate = Date()
    @State private var firstDueDate = Calendar.current.date(byAdding: .day, value: 25, to: Date()) ?? Date()
    @State private var manualKind = PaymentCardKind.credit
    @FocusState private var focusedField: Field?

    private enum Field: Hashable { case last4, bank, name }

    private var selectedPreset: HongKongCardPreset? {
        availablePresets.first { $0.id == selectedPresetID }
    }

    private var availablePresets: [HongKongCardPreset] {
        CardCatalog.presets(in: selectedMarket).filter { $0.issuerName == selectedIssuerName }
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 18) {
                    Picker(strings.market, selection: $selectedMarket) {
                        ForEach(CardMarket.allCases) { Text(strings.marketName($0)).tag($0) }
                    }
                    .pickerStyle(.segmented).accessibilityIdentifier("cards.market")
                    .onChange(of: selectedMarket) { _, market in
                        selectedIssuerName = CardCatalog.issuerNames(in: market).first ?? ""
                        selectedPresetID = CardCatalog.presets(in: market).first?.id ?? ""
                    }
                    Picker(strings.cardType, selection: $entryMode) {
                        Text(strings.cardPresets).tag(0)
                        Text(strings.manualCard).tag(1)
                    }.pickerStyle(.segmented)
                    if entryMode == 0 { presetSection } else { manualSection }
                }.padding(20)
            }
            .background(DashboardBackground())
            .scrollDismissesKeyboard(.interactively)
            .safeAreaInset(edge: .bottom, spacing: 0) {
                if focusedField != nil { KeyboardDismissBar { focusedField = nil } }
            }
            .navigationTitle(strings.addCard).navigationBarTitleDisplayMode(.inline)
            .toolbar { ToolbarItem(placement: .cancellationAction) { Button(strings.cancel) { dismiss() } } }
        }
    }

    private var presetSection: some View {
        DashboardCard {
            VStack(alignment: .leading, spacing: 16) {
                DashboardLabel(strings.cardPresets)

                Picker(strings.company, selection: $selectedIssuerName) {
                    ForEach(CardCatalog.issuerNames(in: selectedMarket), id: \.self) { issuerName in
                        Text(issuerName).tag(issuerName)
                    }
                }
                .pickerStyle(.menu)
                .accessibilityIdentifier("cards.issuer")
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(12)
                .background(DashboardStyle.surface, in: RoundedRectangle(cornerRadius: 10))
                .onChange(of: selectedIssuerName) { _, newIssuerName in
                    selectedPresetID = CardCatalog.presets(in: selectedMarket).first { $0.issuerName == newIssuerName }?.id ?? ""
                }

                Picker(strings.cardName, selection: $selectedPresetID) {
                    ForEach(availablePresets) { preset in
                        Text(preset.displayName).tag(preset.id)
                    }
                }
                .pickerStyle(.menu)
                .accessibilityIdentifier("cards.product")
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(12)
                .background(DashboardStyle.surface, in: RoundedRectangle(cornerRadius: 8))

                if let selectedPreset {
                    KnownCardPreview(preset: selectedPreset)
                    Text("\(selectedPreset.currencyCode) · \(strings.cardKind(selectedPreset.kind))")
                        .font(.subheadline)
                    if selectedPreset.kind == .credit { firstCycleInputs }
                    if let url = selectedPreset.sourceURL {
                        Link(destination: url) { Label(strings.officialCardInfo, systemImage: "arrow.up.right.square") }
                    }
                }

                lastFourField

                Button {
                    addPresetCard()
                } label: {
                    Label(strings.addPresetCard, systemImage: "plus.circle.fill")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity, minHeight: 50)
                        .background(canAddPreset ? DashboardStyle.primary : DashboardStyle.surfaceHigh, in: RoundedRectangle(cornerRadius: 10))
                }
                .buttonStyle(.plain)
                .disabled(!canAddPreset)
                .accessibilityIdentifier("cards.addPreset")
            }
        }
    }

    private var manualSection: some View {
        DashboardCard {
            VStack(alignment: .leading, spacing: 16) {
                DashboardLabel(strings.manualCard)

                Picker(strings.cardType, selection: $manualKind) {
                    ForEach(PaymentCardKind.allCases, id: \.self) { kind in
                        Text(strings.cardKind(kind)).tag(kind)
                    }
                }
                .pickerStyle(.menu)
                Text(selectedMarket.currencyCode).font(.subheadline)

                CardInputField(title: strings.bankIssuer, systemImage: "building.columns.fill") {
                    TextField(strings.bankNamePlaceholder, text: $customBankName)
                        .focused($focusedField, equals: .bank)
                        .font(.system(size: 17, weight: .semibold))
                        .textInputAutocapitalization(.words)
                }

                CardInputField(title: strings.cardName, systemImage: "creditcard.fill") {
                    TextField(strings.cardName, text: $customDisplayName)
                        .focused($focusedField, equals: .name)
                        .font(.system(size: 17, weight: .semibold))
                        .textInputAutocapitalization(.words)
                }

                lastFourField
                if manualKind == .credit { firstCycleInputs }

                Button {
                    addManualCard()
                } label: {
                    Label(strings.addManualCard, systemImage: "plus.circle.fill")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity, minHeight: 50)
                        .background(canAddManual ? DashboardStyle.primary : DashboardStyle.surfaceHigh, in: RoundedRectangle(cornerRadius: 10))
                }
                .buttonStyle(.plain)
                .disabled(!canAddManual)
            }
        }
    }

    private var lastFourField: some View {
                CardInputField(title: strings.last4Digits, systemImage: "number") {
                    TextField("1234", text: $last4)
                        .focused($focusedField, equals: .last4)
                        .accessibilityIdentifier("cards.last4")
                        .keyboardType(.numberPad)
                        .font(.system(size: 17, weight: .semibold, design: .rounded))
                        .onChange(of: last4) { _, newValue in
                            last4 = String(newValue.filter(\.isNumber).prefix(4))
                        }
                }

    }

    private var canAddPreset: Bool {
        selectedPreset != nil && (last4.count == 4 || (selectedPreset?.kind == .storedValue && last4.isEmpty)) && (selectedPreset?.kind != .credit || validFirstCycle)
    }

    private var canAddManual: Bool {
        !customBankName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
            !customDisplayName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
            (last4.count == 4 || (manualKind == .storedValue && last4.isEmpty)) && (manualKind != .credit || validFirstCycle)
    }

    private var firstCycleInputs: some View {
        VStack(alignment: .leading, spacing: 10) {
            DatePicker(strings.firstStatement, selection: $firstStatementDate, displayedComponents: .date)
                .onChange(of: firstStatementDate) { _, date in
                    if firstDueDate <= date { firstDueDate = Calendar.current.date(byAdding: .day, value: 25, to: date) ?? date }
                }
            DatePicker(strings.firstPaymentDue, selection: $firstDueDate, in: firstStatementDate..., displayedComponents: .date)
            Text(strings.statementDateNotice).font(.footnote).foregroundStyle(DashboardStyle.secondaryText)
        }
    }

    private var validFirstCycle: Bool {
        (1...60).contains(firstDueOffset)
    }

    private var firstDueOffset: Int {
        Calendar.current.dateComponents([.day], from: Calendar.current.startOfDay(for: firstStatementDate),
                                        to: Calendar.current.startOfDay(for: firstDueDate)).day ?? 0
    }

    private func insertFirstCycle(for card: CreditCard) {
        guard card.requiresRepayment else { return }
        let calendar = Calendar.current
        let statement = calendar.startOfDay(for: firstStatementDate)
        let previousMonth = calendar.date(byAdding: .month, value: -1, to: statement)!
        let previousStatement = calendar.date(bySettingHour: 0, minute: 0, second: 0, of: previousMonth)!
        let start = calendar.date(byAdding: .day, value: 1, to: previousStatement)!
        modelContext.insert(StatementCycle(cardID: card.id, startDate: start, endDate: statement,
                                          statementDate: statement, dueDate: calendar.startOfDay(for: firstDueDate), isManualDate: true))
    }

    private func addPresetCard() {
        guard canAddPreset, let selectedPreset else { return }
        let card = CreditCard(
            bankName: selectedPreset.issuerName,
            displayName: selectedPreset.displayName,
            last4: last4,
            cardImageFileName: selectedPreset.id,
            statementDay: Calendar.current.component(.day, from: firstStatementDate),
            dueRuleKind: .daysAfterStatement,
            dueDayOrOffset: firstDueOffset,
            billingCurrencyCode: selectedPreset.currencyCode,
            paymentKind: selectedPreset.kind
        )
        modelContext.insert(card)
        insertFirstCycle(for: card)
        focusedField = nil
        dismiss()
        last4 = ""
    }

    private func addManualCard() {
        guard canAddManual else { return }
        let bankName = customBankName.trimmingCharacters(in: .whitespacesAndNewlines)
        let displayName = customDisplayName.trimmingCharacters(in: .whitespacesAndNewlines)
        let card = CreditCard(
            bankName: bankName,
            displayName: displayName,
            last4: last4,
            statementDay: Calendar.current.component(.day, from: firstStatementDate),
            dueRuleKind: .daysAfterStatement,
            dueDayOrOffset: firstDueOffset,
            billingCurrencyCode: selectedMarket.currencyCode,
            paymentKind: manualKind
        )
        modelContext.insert(card)
        insertFirstCycle(for: card)
        focusedField = nil
        dismiss()
        customBankName = ""
        customDisplayName = ""
        last4 = ""
    }

}

private struct KnownCardPreview: View {
    let preset: HongKongCardPreset
    var body: some View {
        CardArtworkView(presetID: preset.id, title: preset.displayName, face: KnownCardInterface.interface(for: preset))
    }
}

private struct CardInputField<Content: View>: View {
    let title: String
    let systemImage: String
    let content: Content

    init(title: String, systemImage: String, @ViewBuilder content: () -> Content) {
        self.title = title
        self.systemImage = systemImage
        self.content = content()
    }

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: systemImage)
                .font(.system(size: 18, weight: .semibold))
                .foregroundStyle(DashboardStyle.secondary)
                .frame(width: 34, height: 34)
                .background(DashboardStyle.surface, in: RoundedRectangle(cornerRadius: 8))

            VStack(alignment: .leading, spacing: 4) {
                DashboardLabel(title)
                content
            }
        }
        .padding(12)
        .background(DashboardStyle.surface, in: RoundedRectangle(cornerRadius: 10))
    }
}

struct KnownCardInterface {
    let colors: [Color]
    let badge: String
    let network: String
    let symbol: String

    static func interface(for card: CreditCard) -> KnownCardInterface {
        if let cardImageFileName = card.cardImageFileName {
            return interface(forID: cardImageFileName)
        }

        let identity = "\(card.bankName) \(card.displayName)".lowercased()
        if identity.contains("hsbc") { return interface(forID: "hsbc-red") }
        if identity.contains("hang seng") { return interface(forID: "hang-seng-enjoy") }
        if identity.contains("standard chartered") { return interface(forID: "standard-chartered-smart") }
        if identity.contains("bank of china") || identity.contains("boc") { return interface(forID: "boc-hk") }
        if identity.contains("citi") { return interface(forID: "citi-cash-back") }
        if identity.contains("dbs") { return interface(forID: "dbs-black") }
        if identity.contains("aeon") { return interface(forID: "aeon") }
        if identity.contains("american express") || identity.contains("amex") { return interface(forID: "amex") }
        if identity.contains("za bank") || identity.contains("za card") { return interface(forID: "za-card") }
        if identity.contains("mox") { return interface(forID: "mox-credit") }
        if identity.contains("octopus") { return interface(forID: "octopus-card") }
        if identity.contains("dah sing") { return interface(forID: "dah-sing") }
        if identity.contains("east asia") || identity.contains("bea") { return interface(forID: "bea") }
        return interface(forID: "generic")
    }

    static func interface(for preset: HongKongCardPreset) -> KnownCardInterface {
        interface(forID: preset.id)
    }

    private static func interface(forID id: String) -> KnownCardInterface {
        let id = legacyFaceID(for: id)
        let product = productFace(forID: id)

        if id.hasPrefix("tw-"), let preset = CardCatalog.preset(id: id) {
            let palette: [Color] = id.contains("esun") || id.contains("cathay")
                ? [Color(red: 0.02, green: 0.44, blue: 0.32), Color(red: 0.12, green: 0.28, blue: 0.25)]
                : [Color(red: 0.65, green: 0.10, blue: 0.17), Color(red: 0.25, green: 0.15, blue: 0.24)]
            return face(palette, preset.issuerName, "TWD", "creditcard.fill")
        }

        if id.hasPrefix("hsbc-") {
            return face([Color(red: 0.78, green: 0.03, blue: 0.08), product.accent], "HSBC", product.label, product.symbol)
        }
        if id.hasPrefix("hang-seng-") {
            return face([Color(red: 0.04, green: 0.45, blue: 0.23), product.accent], "HASE", product.label, product.symbol)
        }
        if id.hasPrefix("standard-chartered-") {
            return face([Color(red: 0.00, green: 0.38, blue: 0.72), product.accent], "SC", product.label, product.symbol)
        }
        if id.hasPrefix("citi-") {
            return face([Color(red: 0.02, green: 0.18, blue: 0.48), product.accent], "CITI", product.label, product.symbol)
        }
        if id.hasPrefix("boc-") {
            return face([Color(red: 0.72, green: 0.00, blue: 0.04), product.accent], "BOC", product.label, product.symbol)
        }
        if id.hasPrefix("dbs-") {
            return face([Color(red: 0.02, green: 0.02, blue: 0.03), product.accent], "DBS", product.label, product.symbol)
        }
        if id.hasPrefix("primecredit-") {
            return face([Color(red: 0.95, green: 0.42, blue: 0.06), product.accent], "PC", product.label, product.symbol)
        }
        if id.hasPrefix("aeon-") {
            return face([Color(red: 0.56, green: 0.04, blue: 0.44), product.accent], "AEON", product.label, product.symbol)
        }
        if id.hasPrefix("amex-") {
            return face([Color(red: 0.05, green: 0.40, blue: 0.62), product.accent], "AMEX", product.label, product.symbol)
        }
        if id.hasPrefix("za-") {
            return face([Color(red: 0.00, green: 0.62, blue: 0.48), product.accent], "ZA", product.label, product.symbol)
        }
        if id.hasPrefix("mox-") {
            return face([Color(red: 0.06, green: 0.06, blue: 0.07), product.accent], "MOX", product.label, product.symbol)
        }
        if id.hasPrefix("octopus-") {
            return face([Color(red: 0.96, green: 0.48, blue: 0.02), product.accent], "OCT", product.label, product.symbol)
        }
        if id.hasPrefix("dah-sing-") {
            return face([Color(red: 0.82, green: 0.15, blue: 0.03), product.accent], "DSB", product.label, product.symbol)
        }
        if id.hasPrefix("bea-") {
            return face([Color(red: 0.62, green: 0.02, blue: 0.08), product.accent], "BEA", product.label, product.symbol)
        }

        return face([DashboardStyle.primaryContainer, DashboardStyle.secondary], "CARD", "Credit", "creditcard.fill")
    }

    private static func legacyFaceID(for id: String) -> String {
        switch id {
        case "amex":
            return "amex-card"
        case "aeon":
            return "aeon-visa"
        case "dbs-black":
            return "dbs-black-world-mastercard"
        case "boc-hk":
            return "boc-bliss"
        case "dah-sing":
            return "dah-sing-credit"
        case "bea":
            return "bea-credit"
        default:
            return id
        }
    }

    private static func face(_ colors: [Color], _ badge: String, _ network: String, _ symbol: String) -> KnownCardInterface {
        KnownCardInterface(colors: colors, badge: badge, network: network, symbol: symbol)
    }

    private static func productFace(forID id: String) -> (label: String, symbol: String, accent: Color) {
        if id.contains("everymile") { return ("EveryMile", "airplane.departure", Color(red: 0.03, green: 0.29, blue: 0.58)) }
        if id.contains("red") { return ("Red Credit", "diamond.fill", Color(red: 0.18, green: 0.02, blue: 0.04)) }
        if id.contains("signature") { return ("Visa Signature", "signature", Color(red: 0.13, green: 0.12, blue: 0.42)) }
        if id.contains("easy") { return ("easy", "hand.thumbsup.fill", Color(red: 0.96, green: 0.58, blue: 0.10)) }
        if id.contains("premier") { return ("Premier", "crown.fill", Color(red: 0.10, green: 0.10, blue: 0.12)) }
        if id.contains("pulse") { return ("Pulse Dual", "waveform.path.ecg", Color(red: 0.55, green: 0.00, blue: 0.14)) }
        if id.contains("students") { return ("Student Gold", "graduationcap.fill", Color(red: 0.83, green: 0.58, blue: 0.19)) }
        if id.contains("gold") { return ("Gold", "star.circle.fill", Color(red: 0.78, green: 0.55, blue: 0.16)) }
        if id.contains("unionpay") { return ("UnionPay", "globe.asia.australia.fill", Color(red: 0.00, green: 0.31, blue: 0.63)) }
        if id.contains("mmpower") { return ("MMPOWER", "bolt.heart.fill", Color(red: 0.00, green: 0.22, blue: 0.18)) }
        if id.contains("travel-plus") { return ("Travel+", "airplane.circle.fill", Color(red: 0.00, green: 0.28, blue: 0.54)) }
        if id.contains("enjoy") { return ("enJoy", "fork.knife.circle.fill", Color(red: 0.02, green: 0.18, blue: 0.12)) }
        if id.contains("cathay") { return ("Cathay Miles", "airplane", Color(red: 0.00, green: 0.42, blue: 0.44)) }
        if id.contains("smart") { return ("Smart", "bolt.fill", Color(red: 0.00, green: 0.55, blue: 0.35)) }
        if id.contains("simply-cash") { return ("Simply Cash", "dollarsign.circle.fill", Color(red: 0.00, green: 0.44, blue: 0.28)) }
        if id.contains("apoint") { return ("A.Point", "a.circle.fill", Color(red: 0.00, green: 0.52, blue: 0.64)) }
        if id.contains("prestige") { return ("Prestige", "sparkle.magnifyingglass", Color(red: 0.01, green: 0.01, blue: 0.02)) }
        if id.contains("premiermiles") { return ("PremierMiles", "airplane.departure", Color(red: 0.00, green: 0.47, blue: 0.76)) }
        if id.contains("cash-back") { return ("Cash Back", "arrow.counterclockwise.circle.fill", Color(red: 0.00, green: 0.47, blue: 0.76)) }
        if id.contains("rewards") { return ("Rewards", "gift.fill", Color(red: 0.28, green: 0.07, blue: 0.56)) }
        if id.contains("plus") { return ("Plus", "plus.circle.fill", Color(red: 0.00, green: 0.50, blue: 0.76)) }
        if id.contains("octopus") { return ("Octopus", "tram.fill", Color(red: 0.95, green: 0.49, blue: 0.05)) }
        if id.contains("hktvmall") { return ("HKTVmall", "cart.fill", Color(red: 0.91, green: 0.05, blue: 0.34)) }
        if id.contains("the-club") { return ("The Club", "ticket.fill", Color(red: 0.26, green: 0.09, blue: 0.42)) }
        if id.contains("bliss") { return ("Bliss", "sparkles", Color(red: 0.93, green: 0.42, blue: 0.72)) }
        if id.contains("cheers") { return ("Cheers", "wineglass.fill", Color(red: 0.78, green: 0.38, blue: 0.09)) }
        if id.contains("chill") { return ("Chill", "snowflake", Color(red: 0.16, green: 0.48, blue: 0.82)) }
        if id.contains("black") { return ("Black", "suit.diamond.fill", Color(red: 0.36, green: 0.02, blue: 0.05)) }
        if id.contains("eminent") { return ("Eminent", "seal.fill", Color(red: 0.63, green: 0.50, blue: 0.25)) }
        if id.contains("compass") { return ("COMPASS", "location.north.circle.fill", Color(red: 0.78, green: 0.09, blue: 0.12)) }
        if id.contains("live-fresh") { return ("Live Fresh", "leaf.fill", Color(red: 0.05, green: 0.54, blue: 0.35)) }
        if id.contains("business") { return ("Business", "briefcase.fill", Color(red: 0.14, green: 0.18, blue: 0.25)) }
        if id.contains("earnmore") { return ("EarnMORE", "dollarsign.arrow.circlepath", Color(red: 0.72, green: 0.12, blue: 0.07)) }
        if id.contains("wewa") { return ("WeWa", "music.note.tv.fill", Color(red: 0.68, green: 0.04, blue: 0.35)) }
        if id.contains("wakuwaku") { return ("WAKUWAKU", "sparkles.tv.fill", Color(red: 0.93, green: 0.24, blue: 0.54)) }
        if id.contains("jcb") { return ("JCB", "j.circle.fill", Color(red: 0.07, green: 0.36, blue: 0.63)) }
        if id.contains("jal") { return ("JAL", "airplane.circle.fill", Color(red: 0.82, green: 0.00, blue: 0.08)) }
        if id.contains("premium") { return ("Premium", "crown.fill", Color(red: 0.14, green: 0.10, blue: 0.18)) }
        if id.contains("watami") { return ("Watami", "fork.knife", Color(red: 0.75, green: 0.11, blue: 0.08)) }
        if id.contains("drmax") { return ("DR-MAX", "book.fill", Color(red: 0.02, green: 0.24, blue: 0.50)) }
        if id.contains("spca-puppy") { return ("SPCA Puppy", "heart.circle.fill", Color(red: 0.07, green: 0.42, blue: 0.34)) }
        if id.contains("spca-kitten") { return ("SPCA Kitten", "heart.circle.fill", Color(red: 0.30, green: 0.30, blue: 0.46)) }
        if id.contains("platinum-card") { return ("Platinum", "rectangle.portrait.on.rectangle.portrait.fill", Color(red: 0.66, green: 0.77, blue: 0.82)) }
        if id.contains("explorer") { return ("Explorer", "safari.fill", Color(red: 0.05, green: 0.23, blue: 0.48)) }
        if id.contains("platinum-credit") { return ("Platinum Credit", "creditcard.fill", Color(red: 0.52, green: 0.60, blue: 0.65)) }
        if id.contains("blue-cash") { return ("Blue Cash", "drop.fill", Color(red: 0.00, green: 0.26, blue: 0.68)) }
        if id.contains("essential") { return ("Essential", "checkmark.seal.fill", Color(red: 0.11, green: 0.32, blue: 0.48)) }
        if id.contains("peninsula") { return ("Peninsula", "building.2.fill", Color(red: 0.58, green: 0.44, blue: 0.22)) }
        if id.contains("corporate") { return ("Corporate", "building.2.crop.circle.fill", Color(red: 0.10, green: 0.14, blue: 0.20)) }
        if id.contains("za-card") { return ("ZA Card", "creditcard.fill", Color(red: 0.06, green: 0.20, blue: 0.18)) }
        if id.contains("mox-credit") { return ("Mox Credit", "creditcard.fill", Color(red: 0.38, green: 0.20, blue: 0.86)) }
        if id.contains("mox-card") { return ("Mox Card", "wallet.pass.fill", Color(red: 0.16, green: 0.49, blue: 0.86)) }
        if id.contains("octopus-card") { return ("Octopus", "tram.fill", Color(red: 0.36, green: 0.13, blue: 0.04)) }
        return ("Credit", "creditcard.fill", DashboardStyle.secondary)
    }
}
