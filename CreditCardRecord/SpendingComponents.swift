import SwiftUI
import SwiftData
import Charts

extension AppStrings {
    var addCard: String { text("Add Card", traditional: "新增卡片", simplified: "添加卡片") }
    var overview: String { text("Overview", traditional: "總覽", simplified: "总览") }
    var recentTransactions: String { text("Transactions", traditional: "交易記錄", simplified: "交易记录") }
    var noTransactions: String { text("No spending yet", traditional: "暫無消費記錄", simplified: "暂无消费记录") }
    var defaultCard: String { text("Default Card", traditional: "預設卡片", simplified: "默认卡片") }
    var defaultCategory: String { text("Default Category", traditional: "預設類別", simplified: "默认类别") }
    var privacy: String { text("Hide Amounts", traditional: "隱藏金額", simplified: "隐藏金额") }
    var recording: String { text("Recording", traditional: "記帳偏好", simplified: "记账偏好") }
    var allSpending: String { text("All spending", traditional: "全部消費", simplified: "全部消费") }
    var saved: String { text("Saved", traditional: "已儲存", simplified: "已保存") }
    var dataTitle: String { text("Local Records", traditional: "本機資料", simplified: "本机数据") }
    var reportingCurrency: String { text("Reporting Currency", traditional: "統計幣別", simplified: "统计币种") }
    var chooseCard: String { text("Choose Card", traditional: "選擇卡片", simplified: "选择卡片") }
    var selectCategory: String { text("Choose Category", traditional: "選擇類別", simplified: "选择类别") }
    var monthlyTrend: String { text("Monthly Trend", traditional: "每月趨勢", simplified: "每月趋势") }
    var cardActivity: String { text("Card Activity", traditional: "卡片消費", simplified: "卡片消费") }
    var cardNickname: String { text("Card Name", traditional: "卡片名稱", simplified: "卡片名称") }
    var automaticChoice: String { text("First Available", traditional: "第一張可用卡片", simplified: "第一张可用卡片") }
    var estimated: String { text("Estimated", traditional: "預測", simplified: "预测") }
    var noCreditCards: String { text("No credit cards awaiting payment", traditional: "暫無信用卡待還款", simplified: "暂无信用卡待还款") }
}

extension SpendingCategoryOption {
    var color: Color {
        switch self {
        case .dining, .health: Color(red: 0.78, green: 0.26, blue: 0.36)
        case .transport, .online: Color(red: 0.16, green: 0.39, blue: 0.73)
        case .grocery, .bills: Color(red: 0.12, green: 0.46, blue: 0.36)
        case .shopping, .education: Color(red: 0.55, green: 0.30, blue: 0.65)
        case .entertainment, .travel: Color(red: 0.63, green: 0.40, blue: 0.08)
        case .other: Color(red: 0.37, green: 0.41, blue: 0.46)
        }
    }
}

struct CategoryIcon: View {
    let category: String
    var size: CGFloat = 40
    private var option: SpendingCategoryOption { .resolve(category) }
    var body: some View {
        Image(systemName: option.symbolName)
            .font(.system(size: size * 0.44, weight: .semibold))
            .foregroundStyle(option.color)
            .frame(width: size, height: size)
            .background(option.color.opacity(0.12), in: RoundedRectangle(cornerRadius: 8))
            .accessibilityHidden(true)
    }
}

struct CategoryGrid: View {
    @Environment(\.appStrings) private var strings
    @Binding var selection: String
    var body: some View {
        LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 8), count: 3), spacing: 8) {
            ForEach(SpendingCategoryOption.allCases) { category in
                Button { selection = category.rawValue } label: {
                    VStack(spacing: 7) {
                        Image(systemName: category.symbolName)
                            .font(.system(size: 22, weight: .semibold))
                            .foregroundStyle(category.color)
                            .frame(height: 26)
                        Text(strings.categoryDisplayName(for: category.rawValue))
                            .font(.system(size: 12, weight: .semibold))
                            .foregroundStyle(DashboardStyle.text)
                            .lineLimit(2)
                            .multilineTextAlignment(.center)
                            .minimumScaleFactor(0.85)
                            .frame(height: 30)
                    }
                    .frame(maxWidth: .infinity)
                    .frame(height: 84)
                    .background(selection == category.rawValue ? category.color.opacity(0.15) : DashboardStyle.cardSurface,
                                in: RoundedRectangle(cornerRadius: 8))
                    .overlay(RoundedRectangle(cornerRadius: 8).stroke(selection == category.rawValue ? category.color : DashboardStyle.cardBorder, lineWidth: selection == category.rawValue ? 2 : 1))
                    .overlay(alignment: .topTrailing) {
                        if selection == category.rawValue {
                            Image(systemName: "checkmark.circle.fill").font(.system(size: 13))
                                .foregroundStyle(category.color).padding(5)
                        }
                    }
                }
                .buttonStyle(.plain)
                .accessibilityIdentifier("category.\(category.rawValue)")
                .accessibilityAddTraits(selection == category.rawValue ? .isSelected : [])
            }
        }
        .accessibilityIdentifier("category.grid")
    }
}

struct MoneyText: View {
    @AppStorage("hideAmounts") private var hideAmounts = false
    let amount: Decimal
    var currency = "HKD"
    var body: some View {
        Text(hideAmounts ? "••••" : amount.formatted(.currency(code: currency).locale(Locale(identifier: "en_HK"))))
            .monospacedDigit()
            .lineLimit(1).minimumScaleFactor(0.65)
    }
}

struct ScreenActions: ToolbarContent {
    @Environment(\.appStrings) private var strings
    var onAddCard: (() -> Void)?
    let onSettings: () -> Void
    var body: some ToolbarContent {
        ToolbarItemGroup(placement: .topBarTrailing) {
            if let onAddCard {
                Button(action: onAddCard) { Image(systemName: "plus") }
                    .accessibilityLabel(strings.addCard).accessibilityIdentifier("navigation.addCard").help(strings.addCard)
            }
            Button(action: onSettings) { Image(systemName: "gearshape") }
                .accessibilityLabel(strings.settingsTitle).accessibilityIdentifier("navigation.settings").help(strings.settingsTitle)
        }
    }
}

struct MonthSelector: View {
    @Environment(\.appStrings) private var strings
    @Binding var month: Date
    private var isCurrent: Bool { Calendar.current.isDate(month, equalTo: Date(), toGranularity: .month) }
    var body: some View {
        HStack {
            Button { shift(-1) } label: { Image(systemName: "chevron.left").frame(width: 44, height: 44) }
                .accessibilityLabel(strings.text("Previous month", traditional: "上個月", simplified: "上个月"))
            Spacer()
            Text(strings.dateString(month, format: "yyyy MMMM")).font(.system(size: 16, weight: .bold, design: .rounded))
            Spacer()
            Button { shift(1) } label: { Image(systemName: "chevron.right").frame(width: 44, height: 44) }
                .disabled(isCurrent)
                .accessibilityLabel(strings.text("Next month", traditional: "下個月", simplified: "下个月"))
        }
        .foregroundStyle(DashboardStyle.text)
    }
    private func shift(_ value: Int) {
        let calendar = Calendar.current
        let start = calendar.date(from: calendar.dateComponents([.year, .month], from: month)) ?? month
        month = calendar.date(byAdding: .month, value: value, to: start) ?? month
    }
}

struct PaymentCardFace: View {
    @Environment(\.appStrings) private var strings
    let card: CreditCard
    let amount: Decimal
    private var face: KnownCardInterface { .interface(for: card) }
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            CardArtworkView(presetID: card.cardImageFileName, title: card.displayName, face: face)
            HStack(alignment: .top, spacing: 10) {
                VStack(alignment: .leading, spacing: 6) {
                    Text(card.displayName).font(.system(size: 16, weight: .semibold, design: .rounded))
                        .lineLimit(2).minimumScaleFactor(0.8)
                    Text(card.currencyCode + " · " + (card.last4.isEmpty ? strings.cardKind(card.paymentKind) : "•• " + card.last4))
                        .font(.system(size: 12, weight: .medium)).foregroundStyle(DashboardStyle.secondaryText)
                }
                Spacer(minLength: 4)
                VStack(alignment: .trailing, spacing: 6) {
                    Text(strings.cardActivity + " · HKD").font(.system(size: 10, weight: .medium))
                        .foregroundStyle(DashboardStyle.secondaryText).lineLimit(1).minimumScaleFactor(0.8)
                    MoneyText(amount: amount).font(.system(size: 20, weight: .bold, design: .rounded))
                }.frame(maxWidth: 142, alignment: .trailing)
            }
            .padding(.horizontal, 4)
        }
        .padding(.top, 8)
        .frame(maxWidth: .infinity, minHeight: 280, maxHeight: 280, alignment: .top)
        .accessibilityElement(children: .contain)
        .accessibilityIdentifier("card.face.\(card.id)")
    }
}

struct CardCarousel: View {
    @Environment(\.appStrings) private var strings
    let cards: [CreditCard]
    let transactions: [TransactionRecord]
    @Binding var selection: UUID?
    var month = Date()
    @State private var showChoices = false
    private var selected: CreditCard? { cards.first { $0.id == selection } ?? cards.first }

    var body: some View {
        VStack(spacing: 10) {
            HStack {
                Text(strings.selectedCard).font(.system(size: 14, weight: .semibold))
                Spacer()
                Text("\((cards.firstIndex { $0.id == selected?.id } ?? 0) + 1) / \(cards.count)")
                    .font(.system(size: 12, weight: .semibold)).foregroundStyle(DashboardStyle.secondaryText)
                Button { showChoices = true } label: { Image(systemName: "checklist").frame(width: 36, height: 36) }
                    .accessibilityLabel(strings.chooseCard).accessibilityIdentifier("cards.choose").help(strings.chooseCard)
                    .accessibilityValue(selected?.displayName ?? "")
            }
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(cards) { card in
                        PaymentCardFace(card: card, amount: ConsumptionAnalytics.records(from: transactions, cardID: card.id, month: month).reduce(0) { $0 + $1.hkdAmount })
                            .containerRelativeFrame(.horizontal).id(card.id)
                    }
                }
                .scrollTargetLayout()
            }
            .frame(height: 280)
            .scrollTargetBehavior(.viewAligned)
            .scrollPosition(id: $selection)
            .accessibilityIdentifier("cards.carousel")
            HStack(spacing: 6) {
                if cards.count <= 7 {
                    ForEach(cards) { card in
                        Button { withAnimation { selection = card.id } } label: {
                            Circle().fill(selected?.id == card.id ? DashboardStyle.primary : DashboardStyle.outline.opacity(0.35))
                                .frame(width: 6, height: 6).frame(width: 24, height: 24)
                        }
                        .accessibilityLabel(card.displayName)
                    }
                }
            }
            .frame(height: 24)
        }
        .onAppear { normalizeSelection() }
        .onChange(of: cards.map(\.id)) { _, _ in normalizeSelection() }
        .sheet(isPresented: $showChoices) {
            NavigationStack {
                List(cards) { card in
                    Button {
                        selection = card.id
                        showChoices = false
                    } label: {
                        HStack(spacing: 12) {
                            Image(systemName: selected?.id == card.id ? "checkmark.square.fill" : "square")
                                .foregroundStyle(DashboardStyle.primary)
                            VStack(alignment: .leading, spacing: 4) {
                                Text(card.displayName).foregroundStyle(DashboardStyle.text)
                                Text(card.currencyCode + " · " + (card.last4.isEmpty ? strings.cardKind(card.paymentKind) : "•• \(card.last4)"))
                                    .font(.caption).foregroundStyle(DashboardStyle.secondaryText)
                            }
                            Spacer()
                        }.padding(.vertical, 6)
                    }
                    .accessibilityIdentifier("card.choice.\(card.cardImageFileName ?? card.last4)")
                }
                .navigationTitle(strings.chooseCard).navigationBarTitleDisplayMode(.inline)
                .toolbar { ToolbarItem(placement: .cancellationAction) { Button(strings.cancel) { showChoices = false } } }
            }
        }
    }
    private func normalizeSelection() {
        if !cards.contains(where: { $0.id == selection }) { selection = cards.first?.id }
    }
}

struct SpendingBreakdown: View {
    @Environment(\.appStrings) private var strings
    let records: [TransactionRecord]
    private var totals: [SpendingTotal] { ConsumptionAnalytics.categoryTotals(from: records) }
    private var total: Decimal { records.reduce(0) { $0 + $1.hkdAmount } }
    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text(strings.spendingCategories).font(.system(size: 19, weight: .bold, design: .rounded))
            if totals.isEmpty {
                EmptySpendingState()
            } else {
                HStack(spacing: 24) {
                    Chart(totals) { item in
                        SectorMark(angle: .value("HKD", NSDecimalNumber(decimal: item.amount).doubleValue), innerRadius: .ratio(0.7), angularInset: 2)
                            .foregroundStyle(SpendingCategoryOption.resolve(item.id).color)
                            .cornerRadius(4)
                    }
                    .frame(width: 104, height: 104).accessibilityHidden(true)
                    VStack(alignment: .leading, spacing: 5) {
                        Text(strings.topSpendingCategories).font(.caption).foregroundStyle(DashboardStyle.secondaryText)
                        if let first = totals.first {
                            Label(strings.categoryDisplayName(for: first.id), systemImage: SpendingCategoryOption.resolve(first.id).symbolName)
                                .font(.system(size: 16, weight: .semibold)).fixedSize(horizontal: false, vertical: true)
                            MoneyText(amount: first.amount).font(.system(size: 18, weight: .bold, design: .rounded))
                        }
                    }
                }.padding(.vertical, 6)
                ForEach(totals) { item in
                    HStack(spacing: 12) {
                        CategoryIcon(category: item.id, size: 36)
                        Text(strings.categoryDisplayName(for: item.id)).font(.subheadline)
                        Spacer(minLength: 4)
                        VStack(alignment: .trailing, spacing: 3) {
                            MoneyText(amount: item.amount).font(.system(size: 14, weight: .semibold))
                            Text(total > 0 ? "\(Int((NSDecimalNumber(decimal: item.amount / total).doubleValue * 100).rounded()))%" : "0%")
                                .font(.caption).foregroundStyle(DashboardStyle.secondaryText)
                        }
                    }.padding(.vertical, 4)
                }
            }
        }
    }
}

struct EmptySpendingState: View {
    @Environment(\.appStrings) private var strings
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: "leaf.fill").foregroundStyle(DashboardStyle.primary)
                .font(.system(size: 24)).frame(width: 48, height: 48)
                .background(DashboardStyle.secondaryContainer, in: RoundedRectangle(cornerRadius: 8))
            Text(strings.noTransactions).font(.subheadline).foregroundStyle(DashboardStyle.secondaryText)
        }.frame(maxWidth: .infinity, alignment: .leading).padding(.vertical, 24)
    }
}

struct TransactionList: View {
    @Environment(\.appStrings) private var strings
    @AppStorage("hideAmounts") private var hideAmounts = false
    let records: [TransactionRecord]
    let cards: [CreditCard]
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(strings.recentTransactions).font(.system(size: 19, weight: .bold, design: .rounded))
            if records.isEmpty { EmptySpendingState() }
            ForEach(records) { record in
                HStack(spacing: 12) {
                    CategoryIcon(category: record.categoryName)
                    VStack(alignment: .leading, spacing: 4) {
                        Text(record.merchant).font(.system(size: 15, weight: .semibold))
                        Text(strings.categoryDisplayName(for: record.categoryName) + " · " + strings.dateString(record.date, format: "MMM d"))
                            .font(.caption).foregroundStyle(DashboardStyle.secondaryText)
                        if record.importSource == WalletImportRecorder.source {
                            Label(strings.text("Shortcuts", traditional: "捷徑記帳", simplified: "快捷指令记账"), systemImage: "wallet.pass")
                                .font(.caption2).foregroundStyle(DashboardStyle.secondaryText)
                        }
                        if let card = cards.first(where: { $0.id == record.cardID }) {
                            Text(card.displayName).font(.caption2).foregroundStyle(DashboardStyle.secondaryText).lineLimit(1)
                        }
                    }
                    Spacer(minLength: 8)
                    VStack(alignment: .trailing, spacing: 4) {
                        MoneyText(amount: record.hkdAmount).font(.system(size: 14, weight: .bold, design: .rounded))
                        if let original = record.originalAmount, let currency = record.originalCurrencyCode, currency != "HKD" {
                            Text(hideAmounts ? "••••" : original.formatted(.currency(code: currency)))
                                .font(.caption2).foregroundStyle(DashboardStyle.secondaryText)
                        }
                    }.frame(maxWidth: 140, alignment: .trailing)
                }
                .padding(.vertical, 8)
                Divider().overlay(DashboardStyle.cardBorder)
            }
        }
    }
}

struct AddCardEmptyState: View {
    @Environment(\.appStrings) private var strings
    let action: () -> Void
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Image(systemName: "creditcard.and.123").font(.system(size: 30)).foregroundStyle(DashboardStyle.primary)
            Text(strings.noCardsAdded).font(.system(size: 22, weight: .bold, design: .rounded))
            Button(action: action) { Label(strings.addCard, systemImage: "plus").frame(maxWidth: .infinity, minHeight: 48) }
                .buttonStyle(.borderedProminent).tint(DashboardStyle.primary)
                .buttonBorderShape(.roundedRectangle(radius: 8))
                .accessibilityIdentifier("home.addCard")
        }.padding(.vertical, 20)
    }
}
