import Foundation
import SwiftData

enum DueRuleKind: String, Codable, CaseIterable {
    case fixedDayOfMonth
    case daysAfterStatement
}

@Model
final class CreditCard {
    @Attribute(.unique) var id: UUID
    var bankName: String
    var displayName: String
    var last4: String
    var cardImageFileName: String?
    var statementDay: Int
    var dueRuleKindRaw: String
    var dueDayOrOffset: Int
    var isActive: Bool

    init(bankName: String, displayName: String, last4: String, cardImageFileName: String? = nil, statementDay: Int, dueRuleKind: DueRuleKind, dueDayOrOffset: Int, isActive: Bool = true) {
        self.id = UUID()
        self.bankName = bankName
        self.displayName = displayName
        self.last4 = last4
        self.cardImageFileName = cardImageFileName
        self.statementDay = statementDay
        self.dueRuleKindRaw = dueRuleKind.rawValue
        self.dueDayOrOffset = dueDayOrOffset
        self.isActive = isActive
    }

    var dueRuleKind: DueRuleKind {
        DueRuleKind(rawValue: dueRuleKindRaw) ?? .fixedDayOfMonth
    }
}
