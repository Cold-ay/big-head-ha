import Foundation
import SwiftData

@Model
final class RecurringDeduction {
    @Attribute(.unique) var id: UUID
    var cardID: UUID
    var merchant: String
    var categoryName: String
    var hkdAmount: Decimal
    var monthlyDay: Int
    var startDate: Date
    var endDate: Date?
    var isActive: Bool

    init(cardID: UUID, merchant: String, categoryName: String, hkdAmount: Decimal, monthlyDay: Int, startDate: Date, endDate: Date? = nil, isActive: Bool = true) {
        self.id = UUID()
        self.cardID = cardID
        self.merchant = merchant
        self.categoryName = categoryName
        self.hkdAmount = hkdAmount
        self.monthlyDay = min(max(monthlyDay, 1), 31)
        self.startDate = startDate
        self.endDate = endDate
        self.isActive = isActive
    }
}
