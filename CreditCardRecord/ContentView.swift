import SwiftUI
import SwiftData
#if canImport(UIKit)
import UIKit
#endif

struct ContentView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.scenePhase) private var scenePhase
    @AppStorage("appearanceMode") private var appearanceModeRawValue = AppearanceMode.system.rawValue
    @AppStorage("appLanguage") private var appLanguageRawValue = AppLanguage.system.rawValue
    @State private var selectedTab = AppTab.overview
    @State private var showAddCard = false
    @State private var showSettings = false

    private var appLanguage: AppLanguage { AppLanguage(rawValue: appLanguageRawValue) ?? .system }
    private var strings: AppStrings { AppStrings(language: appLanguage) }

    var body: some View {
        TabView(selection: $selectedTab) {
            DashboardView(onAddCard: { showAddCard = true }, onSettings: { showSettings = true })
                .tabItem { Label(strings.overview, systemImage: "square.grid.2x2") }.tag(AppTab.overview)
            QuickAddView(onAddCard: { showAddCard = true }, onSettings: { showSettings = true })
                .tabItem { Label(strings.quickTabTitle, systemImage: "plus.circle.fill") }.tag(AppTab.quickAdd)
            CardsView(onAddCard: { showAddCard = true }, onSettings: { showSettings = true })
                .tabItem { Label(strings.cardsTabTitle, systemImage: "rectangle.stack") }.tag(AppTab.cards)
            RepaymentView(onAddCard: { showAddCard = true }, onSettings: { showSettings = true })
                .tabItem { Label(strings.repaymentTabTitle, systemImage: "calendar") }.tag(AppTab.repayment)
        }
        .sheet(isPresented: $showAddCard) {
            AddCardView().preferredColorScheme(AppearanceMode(rawValue: appearanceModeRawValue)?.colorScheme)
        }
        .sheet(isPresented: $showSettings) { SettingsView() }
        .tint(DashboardStyle.primary)
        .preferredColorScheme(AppearanceMode(rawValue: appearanceModeRawValue)?.colorScheme)
        .environment(\.locale, appLanguage.locale)
        .environment(\.appStrings, strings)
        .onAppear { generateDueRecurringDeductionsIfNeeded() }
        .onChange(of: scenePhase) { _, phase in
            if phase == .active { generateDueRecurringDeductionsIfNeeded() }
        }
    }

    private func generateDueRecurringDeductionsIfNeeded() {
        guard let records = try? modelContext.fetch(FetchDescriptor<TransactionRecord>()),
              let rules = try? modelContext.fetch(FetchDescriptor<RecurringDeduction>()),
              let cards = try? modelContext.fetch(FetchDescriptor<CreditCard>()) else { return }
        var known = records
        for rule in rules where cards.contains(where: { $0.id == rule.cardID }) {
            let additions = RecurringDeductionGenerator.transactionsToCreate(for: rule, existingTransactions: known)
            additions.forEach(modelContext.insert)
            known.append(contentsOf: additions)
        }
    }
}

enum AppTab: String, CaseIterable {
    case overview, quickAdd, cards, repayment
}

enum AppearanceMode: String, CaseIterable, Identifiable {
    case system
    case light
    case dark

    var id: String { rawValue }

    var title: String {
        switch self {
        case .system: "System"
        case .light: "Light"
        case .dark: "Dark"
        }
    }

    func title(in language: AppLanguage) -> String {
        switch language {
        case .system:
            title
        case .traditionalChinese:
            switch self {
            case .system: "系統"
            case .light: "淺色"
            case .dark: "深色"
            }
        case .simplifiedChinese:
            switch self {
            case .system: "系统"
            case .light: "浅色"
            case .dark: "深色"
            }
        }
    }

    var icon: String {
        switch self {
        case .system: "circle.lefthalf.filled"
        case .light: "sun.max.fill"
        case .dark: "moon.stars.fill"
        }
    }

    var colorScheme: ColorScheme? {
        switch self {
        case .system: nil
        case .light: .light
        case .dark: .dark
        }
    }
}

enum AppLanguage: String, CaseIterable, Identifiable {
    case system
    case traditionalChinese = "zh-Hant"
    case simplifiedChinese = "zh-Hans"

    var id: String { rawValue }

    var title: String {
        switch self {
        case .system: "System"
        case .traditionalChinese: "繁體中文"
        case .simplifiedChinese: "简体中文"
        }
    }

    var localeIdentifier: String? {
        switch self {
        case .system: nil
        case .traditionalChinese: "zh-Hant-HK"
        case .simplifiedChinese: "zh-Hans-CN"
        }
    }

    var locale: Locale {
        if let localeIdentifier {
            return Locale(identifier: localeIdentifier)
        }
        return .current
    }

    var dashboardTabTitle: String {
        switch self {
        case .system: "Dashboard"
        case .traditionalChinese: "儀表板"
        case .simplifiedChinese: "仪表板"
        }
    }

    var quickTabTitle: String {
        switch self {
        case .system: "Quick"
        case .traditionalChinese: "快速"
        case .simplifiedChinese: "快速"
        }
    }

    var repaymentTabTitle: String {
        switch self {
        case .system: "Repayment"
        case .traditionalChinese: "還款"
        case .simplifiedChinese: "还款"
        }
    }

    var trendsTabTitle: String {
        switch self {
        case .system: "Trends"
        case .traditionalChinese: "趨勢"
        case .simplifiedChinese: "趋势"
        }
    }

    var cardsTabTitle: String {
        switch self {
        case .system: "Cards"
        case .traditionalChinese: "卡片"
        case .simplifiedChinese: "卡片"
        }
    }

    var preferencesTitle: String {
        switch self {
        case .system: "Preferences"
        case .traditionalChinese: "偏好設定"
        case .simplifiedChinese: "偏好设置"
        }
    }

    var settingsTitle: String {
        switch self {
        case .system: "Settings"
        case .traditionalChinese: "設定"
        case .simplifiedChinese: "设置"
        }
    }

    var appearanceTitle: String {
        switch self {
        case .system: "Appearance"
        case .traditionalChinese: "外觀"
        case .simplifiedChinese: "外观"
        }
    }

    var appearanceDescription: String {
        switch self {
        case .system: "Choose how WealthShield should look."
        case .traditionalChinese: "選擇 WealthShield 的顯示方式。"
        case .simplifiedChinese: "选择 WealthShield 的显示方式。"
        }
    }

    var languageTitle: String {
        switch self {
        case .system: "Language"
        case .traditionalChinese: "語言"
        case .simplifiedChinese: "语言"
        }
    }

    var languageDescription: String {
        switch self {
        case .system: "Choose the app language."
        case .traditionalChinese: "選擇應用程式語言。"
        case .simplifiedChinese: "选择应用程序语言。"
        }
    }

    var previewTitle: String {
        switch self {
        case .system: "Preview"
        case .traditionalChinese: "預覽"
        case .simplifiedChinese: "预览"
        }
    }
}

struct AppStrings {
    let language: AppLanguage

    var dashboardTabTitle: String { overview }
    var quickTabTitle: String { text("Quick", traditional: "快速", simplified: "快速") }
    var repaymentTabTitle: String { text("Repayment", traditional: "還款", simplified: "还款") }
    var trendsTabTitle: String { text("Trends", traditional: "趨勢", simplified: "趋势") }
    var cardsTabTitle: String { text("Cards", traditional: "卡片", simplified: "卡片") }
    var preferencesTitle: String { text("Preferences", traditional: "偏好設定", simplified: "偏好设置") }
    var settingsTitle: String { text("Settings", traditional: "設定", simplified: "设置") }
    var appearanceTitle: String { text("Appearance", traditional: "外觀", simplified: "外观") }
    var appearanceDescription: String { text("Choose how WealthShield should look.", traditional: "選擇 WealthShield 的顯示方式。", simplified: "选择 WealthShield 的显示方式。") }
    var languageTitle: String { text("Language", traditional: "語言", simplified: "语言") }
    var languageDescription: String { text("Choose the app language.", traditional: "選擇應用程式語言。", simplified: "选择应用程序语言。") }
    var previewTitle: String { text("Preview", traditional: "預覽", simplified: "预览") }
    var monthlyDeductionsTitle: String { text("Monthly Deductions", traditional: "每月自動扣款", simplified: "每月自动扣款") }
    var monthlyDeductionsDescription: String { text("Create spending records automatically on a monthly day.", traditional: "在每月指定日期自動建立消費記錄。", simplified: "在每月指定日期自动创建消费记录。") }
    var monthlyDeductionNoCards: String { text("Add a card before creating a monthly deduction.", traditional: "請先新增卡片，再建立每月扣款。", simplified: "请先添加卡片，再创建每月扣款。") }
    var deductionName: String { text("Deduction name", traditional: "扣款名稱", simplified: "扣款名称") }
    var monthlyDay: String { text("Monthly day", traditional: "每月日期", simplified: "每月日期") }
    var startDate: String { text("Start date", traditional: "開始日期", simplified: "开始日期") }
    var endDate: String { text("End date", traditional: "結束日期", simplified: "结束日期") }
    var ongoing: String { text("Ongoing", traditional: "持續", simplified: "持续") }
    var addMonthlyDeduction: String { text("Add Monthly Deduction", traditional: "新增每月扣款", simplified: "添加每月扣款") }
    var active: String { text("Active", traditional: "啟用", simplified: "启用") }
    var inactive: String { text("Inactive", traditional: "停用", simplified: "停用") }
    var noMonthlyDeductions: String { text("No monthly deductions yet", traditional: "尚未建立每月扣款", simplified: "尚未创建每月扣款") }

    var showAmountsAccessibility: String { text("Show amounts", traditional: "顯示金額", simplified: "显示金额") }
    var hideAmountsAccessibility: String { text("Hide amounts", traditional: "隱藏金額", simplified: "隐藏金额") }
    var totalMonthlySpend: String { text("Total Monthly Spend", traditional: "本月總消費", simplified: "本月总消费") }
    var availableCredit: String { text("Available Credit", traditional: "可用信用額", simplified: "可用信用额") }
    var nextBillDate: String { text("Next Bill Date", traditional: "下一張帳單日", simplified: "下一张账单日") }
    var upcomingRepayments: String { text("Upcoming Repayments", traditional: "即將還款", simplified: "即将还款") }
    var viewAll: String { text("View All", traditional: "查看全部", simplified: "查看全部") }
    var dueSoon: String { text("DUE SOON", traditional: "即將到期", simplified: "即将到期") }
    var spendingCategories: String { text("Spending Categories", traditional: "消費類別", simplified: "消费类别") }
    var report: String { text("Report", traditional: "報告", simplified: "报告") }

    var fastCapture: String { text("Fast Capture", traditional: "快速記錄", simplified: "快速记录") }
    var quickAddTitle: String { text("Quick Add", traditional: "快速新增", simplified: "快速添加") }
    var selectedCard: String { text("Selected Card", traditional: "已選卡片", simplified: "已选卡片") }
    var quickAddNoCards: String { text("Add a card to start quick recording", traditional: "新增卡片即可開始快速記錄", simplified: "添加卡片即可开始快速记录") }
    var transaction: String { text("Transaction", traditional: "交易", simplified: "交易") }
    var amount: String { text("Amount", traditional: "金額", simplified: "金额") }
    var merchant: String { text("Merchant", traditional: "商戶", simplified: "商户") }
    var merchantNamePlaceholder: String { text("Merchant name", traditional: "商戶名稱", simplified: "商户名称") }
    var category: String { text("Category", traditional: "類別", simplified: "类别") }
    var saveTransaction: String { text("Save Transaction", traditional: "儲存交易", simplified: "保存交易") }

    var paymentPlanner: String { text("Payment Planner", traditional: "還款規劃", simplified: "还款规划") }
    var repaymentTitle: String { text("Repayment", traditional: "還款", simplified: "还款") }
    var nextPaymentDue: String { text("Next Payment Due", traditional: "下一筆到期還款", simplified: "下一笔到期还款") }
    var repaymentNoCards: String { text("Add a card to start tracking repayment", traditional: "新增卡片即可開始追蹤還款", simplified: "添加卡片即可开始跟踪还款") }
    var allCards: String { text("All Cards", traditional: "全部卡片", simplified: "全部卡片") }

    var financialTrends: String { text("Financial Trends", traditional: "財務趨勢", simplified: "财务趋势") }
    var financialTrendsDescription: String { text("Review your consumption velocity and debt health.", traditional: "檢視你的消費速度與債務健康。", simplified: "查看你的消费速度与债务健康。") }
    var sixMonthConsumption: String { text("6-Month Consumption", traditional: "六個月消費", simplified: "六个月消费") }
    var topSpendingCategories: String { text("Top Spending Categories", traditional: "主要消費類別", simplified: "主要消费类别") }
    var repaymentStrategyTitle: String { text("Repayment Strategy", traditional: "還款策略", simplified: "还款策略") }
    var bulkRepayment: String { text("Execute Bulk Repayment", traditional: "執行批量還款", simplified: "执行批量还款") }
    var addCardForStrategy: String { text("Add a card and record spending to generate a repayment strategy.", traditional: "新增卡片並記錄消費，以產生還款策略。", simplified: "添加卡片并记录消费，以生成还款策略。") }
    var nextDuePrefix: String { text("NEXT DUE", traditional: "下次到期", simplified: "下次到期") }
    var urgent: String { text("URGENT", traditional: "緊急", simplified: "紧急") }
    var normal: String { text("NORMAL", traditional: "正常", simplified: "正常") }

    var wallet: String { text("Wallet", traditional: "錢包", simplified: "钱包") }
    var cardsTitle: String { text("Cards", traditional: "卡片", simplified: "卡片") }
    var activeCards: String { text("Active Cards", traditional: "使用中的卡片", simplified: "使用中的卡片") }
    var noCardsAdded: String { text("No cards added", traditional: "尚未新增卡片", simplified: "尚未添加卡片") }
    var cardsEmptyDescription: String { text("No cards yet", traditional: "尚未有卡片", simplified: "尚无卡片") }
    var cardPresets: String { text("Card Presets", traditional: "預設卡片", simplified: "预设卡片") }
    var market: String { text("Region", traditional: "地區", simplified: "地区") }
    func marketName(_ market: CardMarket) -> String {
        market == .hongKong ? text("Hong Kong", traditional: "香港", simplified: "香港") : text("Taiwan", traditional: "台灣", simplified: "台湾")
    }
    var cardType: String { text("Card type", traditional: "卡片類型", simplified: "卡片类型") }
    func cardKind(_ kind: PaymentCardKind) -> String {
        switch kind {
        case .credit: text("Credit", traditional: "信用卡", simplified: "信用卡")
        case .debit: text("Debit", traditional: "扣賬卡", simplified: "借记卡")
        case .storedValue: text("Stored value", traditional: "儲值卡", simplified: "储值卡")
        }
    }
    var firstStatement: String { text("First statement date", traditional: "首期結單日", simplified: "首期账单日") }
    var firstPaymentDue: String { text("First payment due", traditional: "首期還款到期日", simplified: "首期还款到期日") }
    var statementDateNotice: String { text("Dates must match your statement. Later dates are estimates; bank holidays and terms may change them.", traditional: "請按實際帳單確認日期。後續日期僅為預測，假期及銀行條款可能令日期變動。", simplified: "请按实际账单确认日期。后续日期仅为预测，假期及银行条款可能令日期变动。") }
    var officialCardInfo: String { text("Official card information", traditional: "官方卡片資料", simplified: "官方卡片资料") }
    var currency: String { text("Currency", traditional: "幣別", simplified: "币种") }
    var exchangeRate: String { text("HKD per 1 currency unit", traditional: "每 1 單位外幣兌港幣", simplified: "每 1 单位外币兑港币") }
    var recordedSpendHKD: String { text("Recorded spending (HKD equivalent)", traditional: "已記錄消費（港幣等值）", simplified: "已记录消费（港币等值）") }
    var markPaid: String { text("Mark as paid", traditional: "標記已還款", simplified: "标记已还款") }
    var overdue: String { text("Overdue", traditional: "已逾期", simplified: "已逾期") }
    var hongKongPresets: String { text("Hong Kong Presets", traditional: "香港預設卡片", simplified: "香港预设卡片") }
    var company: String { text("Company", traditional: "公司", simplified: "公司") }
    var creditCard: String { text("Credit Card", traditional: "信用卡", simplified: "信用卡") }
    var last4Digits: String { text("Last 4 digits", traditional: "末四位數字", simplified: "末四位数字") }
    var addPresetCard: String { text("Add Preset Card", traditional: "新增預設卡片", simplified: "添加预设卡片") }
    var manualCard: String { text("Manual Card", traditional: "手動卡片", simplified: "手动卡片") }
    var bankIssuer: String { text("Bank / issuer", traditional: "銀行 / 發卡機構", simplified: "银行 / 发卡机构") }
    var bankNamePlaceholder: String { text("Bank name", traditional: "銀行名稱", simplified: "银行名称") }
    var cardName: String { text("Card name", traditional: "卡片名稱", simplified: "卡片名称") }
    var addManualCard: String { text("Add Manual Card", traditional: "新增手動卡片", simplified: "添加手动卡片") }
    var removeCard: String { text("Remove Card", traditional: "移除卡片", simplified: "移除卡片") }
    var cancel: String { text("Cancel", traditional: "取消", simplified: "取消") }
    var done: String { text("Done", traditional: "完成", simplified: "完成") }
    var remove: String { text("Remove", traditional: "移除", simplified: "移除") }

    func daysLeft(_ days: Int) -> String {
        text("\(days) DAYS LEFT", traditional: "剩餘 \(days) 天", simplified: "剩余 \(days) 天")
    }

    func shortDaysLeft(_ days: Int) -> String {
        text("\(days)d", traditional: "\(days)天", simplified: "\(days)天")
    }

    func dueDate(_ date: Date) -> String {
        text("Due \(dateString(date, format: "MMM d, yyyy"))", traditional: "\(dateString(date, format: "M月d日 yyyy年")) 到期", simplified: "\(dateString(date, format: "yyyy年M月d日")) 到期")
    }

    func daysLeftSentence(_ days: Int) -> String {
        text("\(days) days left", traditional: "剩餘 \(days) 天", simplified: "剩余 \(days) 天")
    }

    func statementDay(_ day: Int) -> String {
        text("statement day \(day)", traditional: "結單日 \(day) 號", simplified: "结单日 \(day) 号")
    }

    func statementAndDue(statementDay: Int, dueOffset: Int) -> String {
        text("Statement \(statementDay), due +\(dueOffset)d", traditional: "結單 \(statementDay) 號，到期 +\(dueOffset) 天", simplified: "结单 \(statementDay) 号，到期 +\(dueOffset) 天")
    }

    func statementStepper(_ day: Int) -> String {
        text("Statement day: \(day)", traditional: "結單日：\(day)", simplified: "结单日：\(day)")
    }

    func dueOffsetStepper(_ days: Int) -> String {
        text("Due offset: \(days) days", traditional: "到期偏移：\(days) 天", simplified: "到期偏移：\(days) 天")
    }

    func strategyMessage(for cardName: String) -> String {
        text(
            "The next recorded or estimated deadline is for \(cardName). Confirm the amount and date on your bank statement.",
            traditional: "\(cardName) 是下一筆已記錄或預測的到期還款。請以銀行帳單確認金額及日期。",
            simplified: "\(cardName) 是下一笔已记录或预测的到期还款。请以银行账单确认金额及日期。"
        )
    }

    func categoryDisplayName(for rawLabel: String) -> String {
        let normalized = rawLabel.lowercased().replacingOccurrences(of: " ", with: "_").replacingOccurrences(of: "&", with: "and")
        switch normalized {
        case "dining", "dining_and_lifestyle":
            return text("Dining", traditional: "餐飲", simplified: "餐饮")
        case "transport":
            return text("Transport", traditional: "交通", simplified: "交通")
        case "grocery":
            return text("Grocery", traditional: "雜貨", simplified: "杂货")
        case "shopping", "luxury_retail":
            return text("Shopping", traditional: "購物", simplified: "购物")
        case "bills", "utilities":
            return text("Bills", traditional: "帳單", simplified: "账单")
        case "entertainment":
            return text("Entertainment", traditional: "娛樂", simplified: "娱乐")
        case "travel", "business_travel", "travel_and_hotel":
            return text("Travel", traditional: "旅遊", simplified: "旅游")
        case "online":
            return text("Online", traditional: "網上消費", simplified: "网上消费")
        case "health":
            return text("Health", traditional: "健康", simplified: "健康")
        case "education":
            return text("Education", traditional: "教育", simplified: "教育")
        case "other":
            return text("Other", traditional: "其他", simplified: "其他")
        default:
            return rawLabel
                .split(separator: "_")
                .map { $0.capitalized }
                .joined(separator: " ")
        }
    }

    func dateString(_ date: Date, format: String) -> String {
        let formatter = DateFormatter()
        formatter.locale = language.localeIdentifier.map(Locale.init(identifier:)) ?? Locale(identifier: "en_HK")
        formatter.dateFormat = format
        return formatter.string(from: date)
    }

    func text(_ system: String, traditional: String, simplified: String) -> String {
        switch language {
        case .system:
            system
        case .traditionalChinese:
            traditional
        case .simplifiedChinese:
            simplified
        }
    }
}

private struct AppStringsKey: EnvironmentKey {
    static let defaultValue = AppStrings(language: .system)
}

extension EnvironmentValues {
    var appStrings: AppStrings {
        get { self[AppStringsKey.self] }
        set { self[AppStringsKey.self] = newValue }
    }
}


private struct DashboardView: View {
    @Environment(\.appStrings) private var strings
    @AppStorage("hideAmounts") private var hideAmounts = false
    @Query(sort: \TransactionRecord.date, order: .reverse) private var transactions: [TransactionRecord]
    @Query private var cards: [CreditCard]
    @State private var month = Date()
    let onAddCard: () -> Void
    let onSettings: () -> Void
    private var records: [TransactionRecord] { ConsumptionAnalytics.records(from: transactions, month: month) }
    private var total: Decimal { records.reduce(0) { $0 + $1.hkdAmount } }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    HStack(spacing: 10) {
                        Image(systemName: "leaf.circle.fill").font(.system(size: 30)).foregroundStyle(DashboardStyle.primary)
                        Text("WealthShield").font(.system(size: 23, weight: .bold, design: .rounded))
                        Spacer()
                        Button { hideAmounts.toggle() } label: {
                            Image(systemName: hideAmounts ? "eye.slash" : "eye").frame(width: 44, height: 44)
                        }.accessibilityLabel(hideAmounts ? strings.showAmountsAccessibility : strings.hideAmountsAccessibility)
                    }
                    if cards.isEmpty { AddCardEmptyState(action: onAddCard) }
                    MonthSelector(month: $month)
                    VStack(alignment: .leading, spacing: 8) {
                        Text(strings.allSpending + " · HKD").font(.subheadline).foregroundStyle(DashboardStyle.secondaryText)
                        MoneyText(amount: total).font(.system(size: 38, weight: .bold, design: .rounded))
                        HStack(spacing: 18) {
                            Label("\(records.count)", systemImage: "list.bullet.rectangle")
                            Label("\(cards.count)", systemImage: "creditcard")
                        }.font(.subheadline).foregroundStyle(DashboardStyle.secondaryText)
                    }.padding(.vertical, 8)
                    Divider()
                    ChartsView(transactions: transactions, month: month)
                    Divider()
                    SpendingBreakdown(records: records)
                    Divider()
                    TransactionList(records: records, cards: cards)
                }
                .padding(.horizontal, 20).padding(.top, 12).padding(.bottom, 36)
            }
            .background(DashboardBackground().ignoresSafeArea())
            .navigationTitle(strings.overview).navigationBarTitleDisplayMode(.inline)
            .toolbar { ScreenActions(onAddCard: onAddCard, onSettings: onSettings) }
        }
    }
}

struct DashboardLabel: View {
    let text: String
    init(_ text: String) { self.text = text }
    var body: some View { Text(text).font(.system(size: 13, weight: .semibold)).foregroundStyle(DashboardStyle.secondaryText) }
}

struct DashboardCard<Content: View>: View {
    let content: Content
    init(@ViewBuilder content: () -> Content) { self.content = content() }
    var body: some View {
        VStack(alignment: .leading, spacing: 0) { content }
            .frame(maxWidth: .infinity, alignment: .leading).padding(.vertical, 12)
    }
}

enum DashboardStyle {
    static let background = adaptive(light: Color(red: 0.97, green: 0.985, blue: 0.98), dark: Color(red: 0.07, green: 0.09, blue: 0.09))
    static let cardSurface = adaptive(light: .white, dark: Color(red: 0.12, green: 0.15, blue: 0.15))
    static let surface = adaptive(light: Color(red: 0.93, green: 0.95, blue: 0.94), dark: Color(red: 0.16, green: 0.20, blue: 0.20))
    static let surfaceHigh = adaptive(light: Color(red: 0.85, green: 0.89, blue: 0.88), dark: Color(red: 0.22, green: 0.27, blue: 0.26))
    static let primary = adaptive(light: Color(red: 0.10, green: 0.39, blue: 0.31), dark: Color(red: 0.48, green: 0.83, blue: 0.68))
    static let primaryContainer = Color(red: 0.06, green: 0.28, blue: 0.24)
    static let secondary = adaptive(light: Color(red: 0.66, green: 0.32, blue: 0.36), dark: Color(red: 0.94, green: 0.64, blue: 0.67))
    static let secondaryContainer = adaptive(light: Color(red: 0.85, green: 0.94, blue: 0.89), dark: Color(red: 0.15, green: 0.28, blue: 0.23))
    static let outline = adaptive(light: Color(red: 0.47, green: 0.53, blue: 0.50), dark: Color(red: 0.58, green: 0.65, blue: 0.62))
    static let text = adaptive(light: Color(red: 0.13, green: 0.19, blue: 0.17), dark: Color(red: 0.93, green: 0.96, blue: 0.94))
    static let secondaryText = adaptive(light: Color(red: 0.36, green: 0.42, blue: 0.40), dark: Color(red: 0.68, green: 0.75, blue: 0.72))
    static let link = primary
    static let errorContainer = adaptive(light: Color(red: 0.99, green: 0.88, blue: 0.88), dark: Color(red: 0.35, green: 0.13, blue: 0.16))
    static let errorText = adaptive(light: Color(red: 0.67, green: 0.16, blue: 0.23), dark: Color(red: 1, green: 0.65, blue: 0.68))
    static let cardBorder = adaptive(light: Color.black.opacity(0.09), dark: Color.white.opacity(0.12))
    static let cardShadow = Color.clear

    private static func adaptive(light: Color, dark: Color) -> Color {
        #if canImport(UIKit)
        Color(UIColor { $0.userInterfaceStyle == .dark ? UIColor(dark) : UIColor(light) })
        #else
        light
        #endif
    }
}

struct DashboardBackground: View { var body: some View { DashboardStyle.background } }

struct KeyboardDismissBar: View {
    @Environment(\.appStrings) private var strings
    let dismiss: () -> Void
    var body: some View {
        HStack {
            Spacer()
            Button(action: dismiss) { Image(systemName: "checkmark").frame(width: 44, height: 44) }
                .accessibilityLabel(strings.done).accessibilityIdentifier("keyboard.done").help(strings.done)
        }.padding(.horizontal, 16).background(.bar)
    }
}

private struct SettingsView: View {
    @Environment(\.appStrings) private var strings
    @Environment(\.colorScheme) private var colorScheme
    @Environment(\.dismiss) private var dismiss
    @AppStorage("appearanceMode") private var appearance = AppearanceMode.system.rawValue
    @AppStorage("appLanguage") private var language = AppLanguage.system.rawValue
    @AppStorage("hideAmounts") private var hideAmounts = false
    @AppStorage("defaultCardID") private var defaultCardID = ""
    @AppStorage("defaultCategory") private var defaultCategory = "dining"
    @Query(sort: \CreditCard.displayName) private var cards: [CreditCard]
    @Query private var transactions: [TransactionRecord]
    @State private var showCategory = false
    @State private var showDefaultCard = false

    private var appearanceAccessibilityValue: String {
        if ProcessInfo.processInfo.arguments.contains("--uitesting") {
            return appearance + ":" + (colorScheme == .dark ? "dark" : "light")
        }
        return (AppearanceMode(rawValue: appearance) ?? .system).title(in: strings.language)
    }

    var body: some View {
        NavigationStack {
            Form {
                Section(strings.recording) {
                    Button { showDefaultCard = true } label: {
                        LabeledContent(strings.defaultCard, value: cards.first { $0.id.uuidString == defaultCardID }?.displayName ?? strings.automaticChoice)
                    }.disabled(cards.isEmpty).accessibilityIdentifier("settings.defaultCard")
                    Button { showCategory = true } label: {
                        HStack {
                            CategoryIcon(category: defaultCategory, size: 32)
                            Text(strings.defaultCategory)
                            Spacer()
                            Text(strings.categoryDisplayName(for: defaultCategory)).foregroundStyle(DashboardStyle.secondaryText)
                        }
                    }.accessibilityIdentifier("settings.defaultCategory")
                    Toggle(isOn: $hideAmounts) { Label(strings.privacy, systemImage: "eye.slash") }
                        .accessibilityIdentifier("settings.privacy")
                    NavigationLink { RecurringPaymentsView() } label: {
                        Label(strings.monthlyDeductionsTitle, systemImage: "repeat")
                    }.accessibilityIdentifier("settings.recurring")
                    Link(destination: URL(string: "shortcuts://")!) {
                        Label(strings.text("Open Shortcuts", traditional: "開啟捷徑", simplified: "打开快捷指令"), systemImage: "arrow.up.forward.app")
                    }.accessibilityIdentifier("settings.shortcuts")
                }
                Section(strings.preferencesTitle) {
                    Picker(strings.languageTitle, selection: $language) {
                        ForEach(AppLanguage.allCases) { Text($0.title).tag($0.rawValue) }
                    }
                    Picker(strings.appearanceTitle, selection: $appearance) {
                        ForEach(AppearanceMode.allCases) { mode in
                            Label(mode.title(in: strings.language), systemImage: mode.icon).tag(mode.rawValue)
                        }
                    }
                    .pickerStyle(.menu)
                    .accessibilityIdentifier("settings.appearance")
                    .accessibilityValue(appearanceAccessibilityValue)
                }
                Section(strings.dataTitle) {
                    LabeledContent(strings.cardsTitle, value: "\(cards.count)")
                    LabeledContent(strings.recentTransactions, value: "\(transactions.count)")
                    LabeledContent(strings.reportingCurrency, value: "HKD")
                }
            }
            .scrollContentBackground(.hidden).background(DashboardBackground())
            .navigationTitle(strings.settingsTitle).navigationBarTitleDisplayMode(.inline)
            .toolbar { ToolbarItem(placement: .confirmationAction) { Button(strings.done) { dismiss() }.accessibilityIdentifier("settings.done") } }
            .sheet(isPresented: $showCategory) {
                NavigationStack {
                    CategoryGrid(selection: $defaultCategory).padding(20).frame(maxHeight: .infinity, alignment: .top)
                        .navigationTitle(strings.defaultCategory).navigationBarTitleDisplayMode(.inline)
                        .toolbar { ToolbarItem(placement: .confirmationAction) { Button(strings.done) { showCategory = false }.accessibilityIdentifier("settings.categoryDone") } }
                }.presentationDetents([.large])
            }
            .sheet(isPresented: $showDefaultCard) {
                NavigationStack {
                    ScrollView {
                        CardCarousel(cards: cards, transactions: transactions, selection: Binding(
                            get: { ConsumptionAnalytics.resolvedCardID(preferred: defaultCardID, cards: cards) },
                            set: { defaultCardID = $0?.uuidString ?? "" }
                        )).padding(20)
                    }
                    .navigationTitle(strings.defaultCard).navigationBarTitleDisplayMode(.inline)
                    .toolbar { ToolbarItem(placement: .confirmationAction) { Button(strings.done) { showDefaultCard = false } } }
                }
            }
        }
        .preferredColorScheme(AppearanceMode(rawValue: appearance)?.colorScheme)
    }
}

private struct RecurringPaymentsView: View {
    @Environment(\.appStrings) private var strings
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \CreditCard.displayName) private var cards: [CreditCard]
    @Query(sort: \RecurringDeduction.merchant) private var recurringDeductions: [RecurringDeduction]
    @Query private var transactions: [TransactionRecord]
    @State private var deductionCardID: UUID?
    @State private var deductionName = ""
    @State private var deductionAmount = ""
    @State private var deductionCategory = "bills"
    @State private var deductionMonthlyDay = 1
    @State private var deductionStartDate = Date()
    @State private var hasDeductionEndDate = false
    @State private var deductionEndDate = Date()
    @FocusState private var editing: Bool

    var body: some View {
        ScrollView { monthlyDeductionsSection.padding(20) }
            .background(DashboardBackground())
            .scrollDismissesKeyboard(.interactively)
            .safeAreaInset(edge: .bottom, spacing: 0) { if editing { KeyboardDismissBar { editing = false } } }
            .navigationTitle(strings.monthlyDeductionsTitle).navigationBarTitleDisplayMode(.inline)
    }

    private var monthlyDeductionsSection: some View {
        DashboardCard {
            VStack(alignment: .leading, spacing: 16) {
                HStack(spacing: 12) {
                    Image(systemName: "calendar.badge.plus")
                        .font(.system(size: 20, weight: .semibold))
                        .foregroundStyle(DashboardStyle.primary)
                        .frame(width: 42, height: 42)
                        .background(DashboardStyle.secondaryContainer, in: RoundedRectangle(cornerRadius: 10))

                    VStack(alignment: .leading, spacing: 4) {
                        Text(strings.monthlyDeductionsTitle)
                            .font(.system(size: 20, weight: .bold, design: .rounded))
                            .foregroundStyle(DashboardStyle.text)
                        Text(strings.monthlyDeductionsDescription)
                            .font(.system(size: 15))
                            .foregroundStyle(DashboardStyle.secondaryText)
                    }
                }

                if cards.isEmpty {
                    Text(strings.monthlyDeductionNoCards)
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundStyle(DashboardStyle.secondaryText)
                        .frame(maxWidth: .infinity, minHeight: 60, alignment: .leading)
                } else {
                    CardCarousel(cards: cards, transactions: transactions, selection: selectedDeductionCardBinding)

                    SettingsInputField(title: strings.deductionName, systemImage: "text.badge.plus") {
                        TextField("Netflix", text: $deductionName).focused($editing)
                            .font(.system(size: 17, weight: .semibold))
                            .textInputAutocapitalization(.words)
                    }

                    SettingsInputField(title: "\(strings.amount) (HKD)", systemImage: "dollarsign.circle.fill") {
                        TextField("0.00", text: $deductionAmount).focused($editing)
                            .keyboardType(.decimalPad)
                            .font(.system(size: 17, weight: .semibold))
                            .onChange(of: deductionAmount) { _, newValue in
                                deductionAmount = AmountInputSanitizer.sanitize(newValue)
                            }
                    }

                    CategoryGrid(selection: $deductionCategory)

                    Stepper("\(strings.monthlyDay): \(deductionMonthlyDay)", value: $deductionMonthlyDay, in: 1...31)
                        .font(.system(size: 15, weight: .semibold))
                        .padding(12)
                        .background(DashboardStyle.surface, in: RoundedRectangle(cornerRadius: 10))

                    DatePicker(strings.startDate, selection: $deductionStartDate, displayedComponents: .date)
                        .font(.system(size: 15, weight: .semibold))
                        .padding(12)
                        .background(DashboardStyle.surface, in: RoundedRectangle(cornerRadius: 10))

                    Toggle(strings.ongoing, isOn: Binding(get: { !hasDeductionEndDate }, set: { hasDeductionEndDate = !$0 }))
                        .font(.system(size: 15, weight: .semibold))
                        .padding(12)
                        .background(DashboardStyle.surface, in: RoundedRectangle(cornerRadius: 10))

                    if hasDeductionEndDate {
                        DatePicker(strings.endDate, selection: $deductionEndDate, in: deductionStartDate..., displayedComponents: .date)
                            .font(.system(size: 15, weight: .semibold))
                            .padding(12)
                            .background(DashboardStyle.surface, in: RoundedRectangle(cornerRadius: 10))
                    }

                    Button {
                        addMonthlyDeduction()
                    } label: {
                        Label(strings.addMonthlyDeduction, systemImage: "plus.circle.fill")
                            .font(.system(size: 16, weight: .bold))
                            .foregroundStyle(.white)
                            .frame(maxWidth: .infinity, minHeight: 50)
                            .background(canAddMonthlyDeduction ? DashboardStyle.primary : DashboardStyle.surfaceHigh, in: RoundedRectangle(cornerRadius: 10))
                    }
                    .buttonStyle(.plain)
                    .disabled(!canAddMonthlyDeduction)
                }

                Divider()

                if recurringDeductions.isEmpty {
                    Text(strings.noMonthlyDeductions)
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundStyle(DashboardStyle.secondaryText)
                } else {
                    VStack(spacing: 10) {
                        ForEach(recurringDeductions) { deduction in
                            RecurringDeductionRow(deduction: deduction, cardName: cardName(for: deduction.cardID), strings: strings) {
                                deduction.isActive.toggle()
                                if deduction.isActive, let existing = try? modelContext.fetch(FetchDescriptor<TransactionRecord>()) {
                                    RecurringDeductionGenerator.transactionsToCreate(for: deduction, existingTransactions: existing)
                                        .forEach(modelContext.insert)
                                }
                            } onRemove: {
                                modelContext.delete(deduction)
                            }
                        }
                    }
                }
            }
        }
    }

    private var selectedDeductionCardBinding: Binding<UUID?> {
        Binding(
            get: { deductionCardID ?? cards.first?.id },
            set: { deductionCardID = $0 }
        )
    }

    private var canAddMonthlyDeduction: Bool {
        cards.contains { $0.id == selectedDeductionCardBinding.wrappedValue } &&
            CurrencyConverter.positiveAmount(deductionAmount) != nil &&
            !deductionName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
            (!hasDeductionEndDate || Calendar.current.startOfDay(for: deductionEndDate) >= Calendar.current.startOfDay(for: deductionStartDate))
    }

    private func addMonthlyDeduction() {
        guard canAddMonthlyDeduction, let cardID = selectedDeductionCardBinding.wrappedValue,
              let amount = CurrencyConverter.positiveAmount(deductionAmount)
        else { return }

        let deduction = RecurringDeduction(
            cardID: cardID,
            merchant: deductionName.trimmingCharacters(in: .whitespacesAndNewlines),
            categoryName: deductionCategory,
            hkdAmount: amount,
            monthlyDay: deductionMonthlyDay,
            startDate: deductionStartDate,
            endDate: hasDeductionEndDate ? deductionEndDate : nil
        )
        modelContext.insert(deduction)
        RecurringDeductionGenerator.transactionsToCreate(for: deduction, existingTransactions: transactions)
            .forEach(modelContext.insert)
        deductionName = ""
        deductionAmount = ""
        deductionCategory = "bills"
        deductionMonthlyDay = 1
        deductionStartDate = Date()
        deductionEndDate = Date()
        hasDeductionEndDate = false
    }

    private func cardName(for cardID: UUID) -> String {
        cards.first { $0.id == cardID }?.displayName ?? "Removed card"
    }
}

private struct RecurringDeductionRow: View {
    let deduction: RecurringDeduction
    let cardName: String
    let strings: AppStrings
    let onToggle: () -> Void
    let onRemove: () -> Void

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: "repeat.circle.fill")
                .font(.system(size: 20, weight: .semibold))
                .foregroundStyle(deduction.isActive ? DashboardStyle.primary : DashboardStyle.secondaryText)
                .frame(width: 38, height: 38)
                .background(DashboardStyle.surface, in: RoundedRectangle(cornerRadius: 10))

            VStack(alignment: .leading, spacing: 4) {
                Text(deduction.merchant)
                    .font(.system(size: 16, weight: .bold, design: .rounded))
                    .foregroundStyle(DashboardStyle.text)
                Text("\(cardName) - \(strings.categoryDisplayName(for: deduction.categoryName))")
                    .font(.system(size: 13))
                    .foregroundStyle(DashboardStyle.secondaryText)
                HStack(spacing: 4) {
                    MoneyText(amount: deduction.hkdAmount)
                    Text("· \(strings.monthlyDay) \(deduction.monthlyDay)")
                }
                .font(.system(size: 13, weight: .semibold))
                .foregroundStyle(DashboardStyle.secondaryText)
            }

            Spacer()

            VStack(spacing: 8) {
                Button(action: onToggle) {
                    Text(deduction.isActive ? strings.active : strings.inactive)
                        .font(.system(size: 12, weight: .bold))
                        .foregroundStyle(deduction.isActive ? .white : DashboardStyle.secondaryText)
                        .padding(.horizontal, 10)
                        .frame(height: 30)
                        .background(deduction.isActive ? DashboardStyle.primary : DashboardStyle.surface, in: Capsule())
                }
                .buttonStyle(.plain)

                Button(role: .destructive, action: onRemove) {
                    Image(systemName: "trash")
                        .font(.system(size: 14, weight: .bold))
                        .foregroundStyle(DashboardStyle.errorText)
                        .frame(width: 30, height: 30)
                        .background(DashboardStyle.errorContainer, in: Circle())
                }
                .buttonStyle(.plain)
            }
        }
        .padding(12)
        .background(DashboardStyle.surface, in: RoundedRectangle(cornerRadius: 10))
    }
}

private struct SettingsInputField<Content: View>: View {
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
