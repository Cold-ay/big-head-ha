import Foundation
import SwiftData

@Model
final class StatementCycle {
    @Attribute(.unique) var id: UUID
    var cardID: UUID
    var startDate: Date
    var endDate: Date
    var statementDate: Date
    var dueDate: Date
    var isManualDate: Bool
    var isPaid: Bool

    init(cardID: UUID, startDate: Date, endDate: Date, statementDate: Date, dueDate: Date, isManualDate: Bool = false, isPaid: Bool = false) {
        self.id = UUID()
        self.cardID = cardID
        self.startDate = startDate
        self.endDate = endDate
        self.statementDate = statementDate
        self.dueDate = dueDate
        self.isManualDate = isManualDate
        self.isPaid = isPaid
    }
}
