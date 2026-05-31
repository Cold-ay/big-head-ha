import Foundation
import SwiftData

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
