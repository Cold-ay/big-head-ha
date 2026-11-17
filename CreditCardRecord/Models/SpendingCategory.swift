import Foundation
import SwiftData

enum SpendingCategoryOption: String, CaseIterable, Identifiable {
    case dining, transport, grocery, shopping, bills, entertainment, travel, online, health, education, other

    var id: String { rawValue }
    var symbolName: String {
        switch self {
        case .dining: "fork.knife"
        case .transport: "tram.fill"
        case .grocery: "carrot.fill"
        case .shopping: "bag.fill"
        case .bills: "doc.text.fill"
        case .entertainment: "gamecontroller.fill"
        case .travel: "airplane"
        case .online: "cart.fill"
        case .health: "heart.fill"
        case .education: "book.fill"
        case .other: "square.grid.2x2.fill"
        }
    }
    static func resolve(_ name: String) -> Self { Self(rawValue: name) ?? .other }
}

@Model
final class SpendingCategory {
    @Attribute(.unique) var id: UUID
    var name: String
    var symbolName: String
    var colorHex: String

    init(name: String, symbolName: String, colorHex: String) {
        self.id = UUID()
        self.name = name
        self.symbolName = symbolName
        self.colorHex = colorHex
    }
}
