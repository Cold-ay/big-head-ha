import SwiftData
import SwiftUI

struct QuickAddView: View {
    @Environment(\.appStrings) private var strings
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \CreditCard.displayName) private var cards: [CreditCard]
    @Query private var transactions: [TransactionRecord]
    @AppStorage("defaultCardID") private var defaultCardID = ""
    @AppStorage("defaultCategory") private var defaultCategory = "dining"
    @State private var amount = ""
    @State private var merchant = ""
    @State private var categoryName = "dining"
    @State private var selectedCardID: UUID?
    @State private var currencyCode = "HKD"
    @State private var rateToHKD = ""
    @State private var date = Date()
    @State private var savedCount = 0
    @State private var initialized = false
    @FocusState private var focusedField: Field?
    var onAddCard: () -> Void = {}
    var onSettings: () -> Void = {}

    private enum Field: Hashable { case amount, merchant, exchangeRate }
    private var availableCards: [CreditCard] { cards.filter(\.isActive) }
    private var selectedID: UUID? {
        availableCards.first { $0.id == selectedCardID }?.id ?? ConsumptionAnalytics.resolvedCardID(preferred: defaultCardID, cards: availableCards)
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 22) {
                    if availableCards.isEmpty {
                        AddCardEmptyState(action: onAddCard).accessibilityIdentifier("quickAdd.noCards")
                    } else {
                        CardCarousel(cards: availableCards, transactions: transactions, selection: $selectedCardID)
                    }
                    HStack(alignment: .firstTextBaseline) {
                        Text(strings.amount).font(.system(size: 14, weight: .semibold)).foregroundStyle(DashboardStyle.secondaryText)
                        Spacer()
                        Picker(strings.currency, selection: $currencyCode) {
                            ForEach(["HKD", "TWD", "USD", "JPY", "CNY", "EUR", "GBP", "KRW"], id: \.self) { Text($0).tag($0) }
                        }.accessibilityIdentifier("quickAdd.currency")
                    }
                    TextField("0.00", text: $amount)
                        .focused($focusedField, equals: .amount).keyboardType(.decimalPad)
                        .font(.system(size: 42, weight: .bold, design: .rounded)).foregroundStyle(DashboardStyle.text)
                        .onChange(of: amount) { _, value in amount = AmountInputSanitizer.sanitize(value) }
                        .accessibilityIdentifier("quickAdd.amount")
                    if currencyCode != "HKD" {
                        VStack(alignment: .leading, spacing: 6) {
                            Text(strings.exchangeRate).font(.caption).foregroundStyle(DashboardStyle.secondaryText)
                            TextField("0.00000000", text: $rateToHKD)
                                .focused($focusedField, equals: .exchangeRate).keyboardType(.decimalPad)
                                .onChange(of: rateToHKD) { _, value in rateToHKD = AmountInputSanitizer.sanitize(value, maximumFractionDigits: 8) }
                                .accessibilityIdentifier("quickAdd.exchangeRate")
                                .padding(12).background(DashboardStyle.surface, in: RoundedRectangle(cornerRadius: 8))
                        }
                    }
                    HStack(spacing: 12) {
                        Image(systemName: "storefront").foregroundStyle(DashboardStyle.primary)
                        TextField(strings.merchantNamePlaceholder, text: $merchant)
                            .focused($focusedField, equals: .merchant).textInputAutocapitalization(.words)
                            .accessibilityIdentifier("quickAdd.merchant")
                    }.padding(14).background(DashboardStyle.cardSurface, in: RoundedRectangle(cornerRadius: 8))
                    DatePicker(strings.text("Date", traditional: "日期", simplified: "日期"), selection: $date, in: ...Date(), displayedComponents: .date)
                    VStack(alignment: .leading, spacing: 12) {
                        Text(strings.category).font(.system(size: 17, weight: .bold, design: .rounded))
                        CategoryGrid(selection: $categoryName)
                    }
                    if savedCount > 0 {
                        Label(strings.saved, systemImage: "checkmark.circle.fill").font(.subheadline).foregroundStyle(DashboardStyle.primary)
                            .accessibilityIdentifier("quickAdd.saved")
                    }
                }.padding(.horizontal, 20).padding(.top, 12).padding(.bottom, 20)
            }
            .scrollDismissesKeyboard(.interactively)
            .background(DashboardBackground().ignoresSafeArea())
            .safeAreaInset(edge: .bottom, spacing: 0) {
                if focusedField != nil {
                    KeyboardDismissBar { focusedField = nil }
                } else {
                    Button(action: saveTransaction) {
                        Label(strings.saveTransaction, systemImage: "checkmark").font(.system(size: 16, weight: .bold))
                            .frame(maxWidth: .infinity, minHeight: 48)
                    }
                    .buttonStyle(.borderedProminent).tint(DashboardStyle.primary)
                    .buttonBorderShape(.roundedRectangle(radius: 8))
                    .disabled(!canSave).accessibilityIdentifier("quickAdd.save")
                    .padding(.horizontal, 20).padding(.vertical, 10).background(.bar)
                }
            }
            .navigationTitle(strings.quickAddTitle).navigationBarTitleDisplayMode(.inline)
            .toolbar { ScreenActions(onAddCard: onAddCard, onSettings: onSettings) }
        }
        .onAppear {
            if !initialized {
                selectedCardID = ConsumptionAnalytics.resolvedCardID(preferred: defaultCardID, cards: availableCards)
                categoryName = SpendingCategoryOption.resolve(defaultCategory).rawValue
                selectCardCurrency()
                initialized = true
            }
        }
        .onChange(of: selectedID) { _, _ in selectCardCurrency() }
        .onChange(of: defaultCategory) { _, value in
            if amount.isEmpty && merchant.isEmpty { categoryName = SpendingCategoryOption.resolve(value).rawValue }
        }
        .onChange(of: defaultCardID) { _, value in
            if amount.isEmpty && merchant.isEmpty {
                selectedCardID = ConsumptionAnalytics.resolvedCardID(preferred: value, cards: availableCards)
            }
        }
        .sensoryFeedback(.success, trigger: savedCount)
    }

    private func selectCardCurrency() {
        currencyCode = availableCards.first { $0.id == selectedID }?.currencyCode ?? "HKD"
        rateToHKD = ""
    }
    private var canSave: Bool {
        CurrencyConverter.positiveAmount(amount) != nil &&
        !merchant.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty && selectedID != nil &&
        (currencyCode == "HKD" || CurrencyConverter.positiveAmount(rateToHKD) != nil)
    }
    private func saveTransaction() {
        guard canSave, let original = CurrencyConverter.positiveAmount(amount), let cardID = selectedID else { return }
        let rate = currencyCode == "HKD" ? Decimal(1) : CurrencyConverter.positiveAmount(rateToHKD)!
        guard let converted = try? CurrencyConverter.convertToHKD(amount: original, rateToHKD: rate) else { return }
        modelContext.insert(TransactionRecord(date: date, merchant: merchant.trimmingCharacters(in: .whitespacesAndNewlines),
            categoryName: categoryName, cardID: cardID, hkdAmount: converted,
            originalAmount: original, originalCurrencyCode: currencyCode, exchangeRateToHKD: rate))
        focusedField = nil
        amount = ""
        merchant = ""
        categoryName = SpendingCategoryOption.resolve(defaultCategory).rawValue
        date = Date()
        savedCount += 1
    }
}
