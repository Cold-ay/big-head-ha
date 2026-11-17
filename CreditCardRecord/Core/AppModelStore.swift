import Foundation
import SwiftData

@MainActor
enum AppModelStore {
    static var schema: Schema {
        Schema([CreditCard.self, TransactionRecord.self, StatementCycle.self, SpendingCategory.self, RecurringDeduction.self])
    }

    // The app and its in-process intents must share the same context for live UI updates.
    static let shared: Result<ModelContainer, Error> = Result {
        try makeContainer(inMemory: ProcessInfo.processInfo.arguments.contains("--uitesting"))
    }

    static func configuration(inMemory: Bool = false) -> ModelConfiguration {
        ModelConfiguration(schema: schema, isStoredInMemoryOnly: inMemory, cloudKitDatabase: .none)
    }

    static func makeContainer(inMemory: Bool = false) throws -> ModelContainer {
        try ModelContainer(for: schema, configurations: configuration(inMemory: inMemory))
    }
}
