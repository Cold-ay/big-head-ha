import AppIntents
import Foundation

struct RecordSpendingIntent: AppIntent {
    static var title: LocalizedStringResource = "Record Spending"
    static var description = IntentDescription("Open Quick Add to record credit card spending.")
    static var openAppWhenRun = true

    @Parameter(title: "Amount")
    var amount: Double?

    @Parameter(title: "Merchant")
    var merchant: String?

    func perform() async throws -> some IntentResult {
        return .result()
    }
}
