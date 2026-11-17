import Foundation
import SwiftData

enum WalletImportError: LocalizedError, Equatable {
    case invalidAmount, invalidMerchant, invalidCurrency, missingExchangeRate, invalidDate, missingCard, referenceConflict

    var errorDescription: String? {
        switch self {
        case .invalidAmount: "Enter a positive purchase amount. Refunds and invalid numbers are not imported."
        case .invalidMerchant: "Provide the merchant from the transaction input."
        case .invalidCurrency: "Provide the transaction's three-letter currency code, such as HKD or TWD."
        case .missingExchangeRate: "A positive HKD exchange rate is required for foreign-currency spending. Nothing was saved."
        case .invalidDate: "Provide a valid transaction date that is not in the future."
        case .missingCard: "The selected app card was removed or is inactive. Select an active card in Shortcuts."
        case .referenceConflict: "This reference already belongs to a different purchase on this card. Nothing was changed."
        }
    }
}

struct WalletImportInput {
    var cardID: UUID
    var amount: Double
    var merchant: String
    var currency: String
    var category = "other"
    var date: Date?
    var exchangeRateToHKD: Double?
    var reference: String?
}

struct WalletImportResult {
    let record: TransactionRecord
    let inserted: Bool
}

@MainActor
enum WalletImportRecorder {
    static let source = "shortcut"

    static func record(_ input: WalletImportInput, in context: ModelContext, now: Date = .now) throws -> WalletImportResult {
        guard let amount = positiveDecimal(input.amount) else { throw WalletImportError.invalidAmount }
        let merchant = input.merchant.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !merchant.isEmpty else { throw WalletImportError.invalidMerchant }
        let currency = input.currency.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()
        guard Locale.commonISOCurrencyCodes.contains(currency) else { throw WalletImportError.invalidCurrency }
        let date = input.date ?? now
        guard date.timeIntervalSince1970.isFinite, date <= now.addingTimeInterval(60) else { throw WalletImportError.invalidDate }
        let rate: Decimal
        if currency == "HKD" {
            rate = 1
        } else {
            guard let value = input.exchangeRateToHKD, let converted = positiveDecimal(value) else { throw WalletImportError.missingExchangeRate }
            rate = converted
        }
        let hkd = try CurrencyConverter.convertToHKD(amount: amount, rateToHKD: rate)
        guard !hkd.isNaN, hkd > 0 else { throw WalletImportError.invalidAmount }
        let cardID = input.cardID
        guard let card = try context.fetch(FetchDescriptor<CreditCard>(predicate: #Predicate { $0.id == cardID })).first,
              card.isActive else { throw WalletImportError.missingCard }
        let reference = input.reference?.trimmingCharacters(in: .whitespacesAndNewlines)
        if let reference, !reference.isEmpty {
            let source = Self.source
            let matches = try context.fetch(FetchDescriptor<TransactionRecord>(predicate: #Predicate {
                $0.cardID == cardID && $0.importSource == source && $0.importReference == reference
            }))
            if let existing = matches.first {
                guard existing.originalAmount == amount, existing.originalCurrencyCode == currency,
                      existing.merchant == merchant else { throw WalletImportError.referenceConflict }
                return WalletImportResult(record: existing, inserted: false)
            }
        }
        let record = TransactionRecord(date: date, merchant: merchant,
            categoryName: SpendingCategoryOption.resolve(input.category).rawValue, cardID: card.id, hkdAmount: hkd,
            originalAmount: amount, originalCurrencyCode: currency, exchangeRateToHKD: rate)
        record.importSource = source
        record.importReference = reference?.isEmpty == false ? reference : nil
        context.insert(record)
        do {
            try context.save()
        } catch {
            context.delete(record)
            throw error
        }
        return WalletImportResult(record: record, inserted: true)
    }

    private static func positiveDecimal(_ value: Double) -> Decimal? {
        guard value.isFinite, value > 0,
              let decimal = Decimal(string: String(value), locale: Locale(identifier: "en_US_POSIX")), !decimal.isNaN else { return nil }
        return decimal
    }
}
