import Foundation
import SwiftData

@Model
final class TransactionRecord {
    @Attribute(.unique) var id: UUID
    var date: Date
    var merchant: String
    var categoryName: String
    var cardID: UUID?
    var hkdAmount: Decimal
    var originalAmount: Decimal?
    var originalCurrencyCode: String?
    var exchangeRateToHKD: Decimal?
    var note: String

    init(date: Date, merchant: String, categoryName: String, cardID: UUID?, hkdAmount: Decimal, originalAmount: Decimal? = nil, originalCurrencyCode: String? = nil, exchangeRateToHKD: Decimal? = nil, note: String = "") {
        self.id = UUID()
        self.date = date
        self.merchant = merchant
        self.categoryName = categoryName
        self.cardID = cardID
        self.hkdAmount = hkdAmount
        self.originalAmount = originalAmount
        self.originalCurrencyCode = originalCurrencyCode
        self.exchangeRateToHKD = exchangeRateToHKD
        self.note = note
    }
}
