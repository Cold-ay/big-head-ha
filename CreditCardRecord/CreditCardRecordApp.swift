import SwiftData
import SwiftUI

@main
struct CreditCardRecordApp: App {
    private let preferences: UserDefaults
    private let container: ModelContainer

    init() {
        if ProcessInfo.processInfo.arguments.contains("--uitesting") {
            let suite = "CreditCardRecord.UITests"
            let defaults = UserDefaults(suiteName: suite)!
            defaults.removePersistentDomain(forName: suite)
            preferences = defaults
        } else {
            preferences = .standard
        }
        do {
            container = try AppModelStore.shared.get()
        } catch {
            fatalError("Unable to open the local record store: \(error)")
        }
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
                .defaultAppStorage(preferences)
        }
        .modelContainer(container)
    }
}
