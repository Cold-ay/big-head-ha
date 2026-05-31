import Foundation
import SwiftData

@Model
final class BootstrapModel {
    var createdAt: Date

    init(createdAt: Date = .now) {
        self.createdAt = createdAt
    }
}
