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
    var billingCurrencyCode: String?
    var paymentKindRaw: String?

    init(bankName: String, displayName: String, last4: String, cardImageFileName: String? = nil, statementDay: Int, dueRuleKind: DueRuleKind, dueDayOrOffset: Int, isActive: Bool = true, billingCurrencyCode: String? = nil, paymentKind: PaymentCardKind? = nil) {
        self.id = UUID()
        self.bankName = bankName
        self.displayName = displayName
        self.last4 = last4
        self.cardImageFileName = cardImageFileName
        self.statementDay = statementDay
        self.dueRuleKindRaw = dueRuleKind.rawValue
        self.dueDayOrOffset = dueDayOrOffset
        self.isActive = isActive
        self.billingCurrencyCode = billingCurrencyCode
        self.paymentKindRaw = paymentKind?.rawValue
    }

    var currencyCode: String { billingCurrencyCode ?? CardCatalog.preset(id: cardImageFileName)?.currencyCode ?? "HKD" }
    var paymentKind: PaymentCardKind {
        paymentKindRaw.flatMap(PaymentCardKind.init(rawValue:)) ?? CardCatalog.preset(id: cardImageFileName)?.kind ?? .credit
    }
    var requiresRepayment: Bool { isActive && paymentKind == .credit }

    var dueRuleKind: DueRuleKind {
        DueRuleKind(rawValue: dueRuleKindRaw) ?? .fixedDayOfMonth
    }
}
