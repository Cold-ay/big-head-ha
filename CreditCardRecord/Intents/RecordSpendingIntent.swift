import AppIntents
import Foundation
import SwiftData

struct RecordSpendingIntent: AppIntent {
    static var title: LocalizedStringResource = "Record Spending"
    static var description = IntentDescription("Save a purchase locally. For Wallet automation, map the transaction amount and merchant in Shortcuts and select the matching card already recorded in this app. This does not read Wallet cards or history.")
    static var openAppWhenRun = false

    @Parameter(title: "App Card")
    var card: SpendingCardEntity

    @Parameter(title: "Amount")
    var amount: Double

    @Parameter(title: "Merchant")
    var merchant: String

    @Parameter(title: "Currency Code")
    var currency: String

    @Parameter(title: "Category", default: .other)
    var category: SpendingShortcutCategory

    @Parameter(title: "Transaction Date")
    var transactionDate: Date?

    @Parameter(title: "HKD per 1 Currency Unit")
    var exchangeRate: Double?

    @Parameter(title: "Transaction Reference")
    var reference: String?

    static var parameterSummary: some ParameterSummary {
        Summary("Record \(\.$amount) \(\.$currency) at \(\.$merchant) on \(\.$card)") {
            \.$category
            \.$transactionDate
            \.$exchangeRate
            \.$reference
        }
    }

    @MainActor
    func perform() async throws -> some IntentResult & ReturnsValue<String> & ProvidesDialog {
        let result = try record(in: AppModelStore.shared.get().mainContext)
        return .result(value: result.record.id.uuidString,
                       dialog: result.inserted ? "Spending recorded." : "Already recorded. No duplicate added.")
    }

    @MainActor
    func record(in context: ModelContext, now: Date = .now) throws -> WalletImportResult {
        try WalletImportRecorder.record(WalletImportInput(cardID: card.id, amount: amount, merchant: merchant,
            currency: currency, category: category.rawValue, date: transactionDate, exchangeRateToHKD: exchangeRate,
            reference: reference), in: context, now: now)
    }
}

struct SpendingCardEntity: AppEntity {
    static var typeDisplayRepresentation: TypeDisplayRepresentation = "App Card"
    static var defaultQuery = SpendingCardQuery()
    let id: UUID
    let name: String
    let bank: String
    let last4: String

    var displayRepresentation: DisplayRepresentation {
        DisplayRepresentation(title: "\(name)", subtitle: "\(bank) \(last4.isEmpty ? "" : "** " + last4)")
    }

    @MainActor
    static func available(in context: ModelContext) throws -> [SpendingCardEntity] {
        try context.fetch(FetchDescriptor<CreditCard>(predicate: #Predicate { $0.isActive }, sortBy: [SortDescriptor(\.displayName)]))
            .map { SpendingCardEntity(id: $0.id, name: $0.displayName, bank: $0.bankName, last4: $0.last4) }
    }
}

struct SpendingCardQuery: EntityStringQuery {
    func entities(for identifiers: [UUID]) async throws -> [SpendingCardEntity] {
        try await cards().filter { identifiers.contains($0.id) }
    }

    func entities(matching string: String) async throws -> [SpendingCardEntity] {
        try await cards().filter { ($0.name + " " + $0.bank + " " + $0.last4).localizedCaseInsensitiveContains(string) }
    }

    func suggestedEntities() async throws -> [SpendingCardEntity] { try await cards() }

    @MainActor
    private func cards() throws -> [SpendingCardEntity] {
        try SpendingCardEntity.available(in: AppModelStore.shared.get().mainContext)
    }
}

enum SpendingShortcutCategory: String, AppEnum {
    case dining, transport, grocery, shopping, bills, entertainment, travel, online, health, education, other
    static var typeDisplayRepresentation: TypeDisplayRepresentation = "Category"
    static var caseDisplayRepresentations: [SpendingShortcutCategory: DisplayRepresentation] = [
        .dining: "Dining", .transport: "Transport", .grocery: "Grocery", .shopping: "Shopping", .bills: "Bills",
        .entertainment: "Entertainment", .travel: "Travel", .online: "Online", .health: "Health", .education: "Education", .other: "Other"
    ]
}

struct SpendingAppShortcuts: AppShortcutsProvider {
    static var appShortcuts: [AppShortcut] {
        AppShortcut(intent: RecordSpendingIntent(), phrases: ["Record spending in \(.applicationName)"],
                    shortTitle: "Record Spending", systemImageName: "plus.circle")
    }
}
