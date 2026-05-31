# Hong Kong Credit Card Tracker MVP Foundation Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Build the native offline iOS 17 foundation for quick credit-card spending capture, statement-cycle repayment logic, encrypted backup logic, and a next-payment widget shell.

**Architecture:** Create one iOS app target plus one widget extension. Keep business logic in small Swift files under `CreditCardRecord/Core` so unit tests can cover date prediction, currency conversion, repayment totals, backup envelopes, and widget snapshots without UI. SwiftData stores user records locally; later UI plans connect these tested services to card setup, notifications, backup screens, and charts.

**Tech Stack:** SwiftUI, SwiftData, WidgetKit, AppIntents, LocalAuthentication, UserNotifications, CryptoKit, XCTest, iOS 17+.

---

## File Structure

- `CreditCardRecord.xcodeproj`: iOS app project with app, widget, and test targets.
- `CreditCardRecord/CreditCardRecordApp.swift`: app entry point and SwiftData container.
- `CreditCardRecord/Models/*.swift`: SwiftData models and value types.
- `CreditCardRecord/Core/*.swift`: pure services for currency, cycles, repayment, backup, widgets.
- `CreditCardRecord/Features/QuickAdd/*.swift`: Quick Add home and transaction form.
- `CreditCardRecord/Features/Repayment/*.swift`: repayment list and detail.
- `CreditCardRecord/Features/Cards/*.swift`: card setup and statement rules.
- `CreditCardRecord/Features/Charts/*.swift`: basic spending charts.
- `CreditCardRecord/Features/Settings/*.swift`: backup/import/privacy settings.
- `CreditCardRecord/Intents/*.swift`: App Intent for Shortcuts/Action Button.
- `CreditCardRecordWidget/*.swift`: WidgetKit extension.
- `CreditCardRecordTests/*.swift`: unit tests.
- `CreditCardRecordUITests/*.swift`: smoke UI tests.

Before execution, install/select full Xcode:

```bash
sudo xcode-select -s /Applications/Xcode.app/Contents/Developer
xcodebuild -version
```

Expected: Xcode version prints instead of CommandLineTools error.

---

### Task 1: Create Xcode Project Skeleton

**Files:**
- Create: `CreditCardRecord.xcodeproj`
- Create: `CreditCardRecord/CreditCardRecordApp.swift`
- Create: `CreditCardRecord/ContentView.swift`
- Create: `CreditCardRecordTests/CreditCardRecordTests.swift`

- [ ] **Step 1: Create project in Xcode**

Create a new iOS App project:

```text
Product Name: CreditCardRecord
Interface: SwiftUI
Language: Swift
Minimum Deployments: iOS 17.0
Use SwiftData: true
Include Tests: true
```

- [ ] **Step 2: Add first failing smoke test**

Create `CreditCardRecordTests/CreditCardRecordTests.swift`:

```swift
import XCTest
@testable import CreditCardRecord

final class CreditCardRecordTests: XCTestCase {
    func testAppNameConstant() {
        XCTAssertEqual(AppConstants.appName, "Credit Card Record")
    }
}
```

- [ ] **Step 3: Run test and verify failure**

Run:

```bash
xcodebuild test -scheme CreditCardRecord -destination 'platform=iOS Simulator,name=iPhone 15'
```

Expected: FAIL because `AppConstants` is not defined.

- [ ] **Step 4: Add minimal constant**

Create `CreditCardRecord/Core/AppConstants.swift`:

```swift
import Foundation

enum AppConstants {
    static let appName = "Credit Card Record"
    static let baseCurrencyCode = "HKD"
    static let appGroupIdentifier = "group.com.local.CreditCardRecord"
}
```

- [ ] **Step 5: Run test and commit**

Run:

```bash
xcodebuild test -scheme CreditCardRecord -destination 'platform=iOS Simulator,name=iPhone 15'
```

Expected: PASS.

Commit:

```bash
git add CreditCardRecord.xcodeproj CreditCardRecord CreditCardRecordTests
git commit -m "chore: create iOS app skeleton"
```

---

### Task 2: Add Domain Models

**Files:**
- Create: `CreditCardRecord/Models/CreditCard.swift`
- Create: `CreditCardRecord/Models/StatementCycle.swift`
- Create: `CreditCardRecord/Models/Transaction.swift`
- Create: `CreditCardRecord/Models/SpendingCategory.swift`
- Test: `CreditCardRecordTests/ModelTests.swift`

- [ ] **Step 1: Write model tests**

Create `CreditCardRecordTests/ModelTests.swift`:

```swift
import XCTest
@testable import CreditCardRecord

final class ModelTests: XCTestCase {
    func testTransactionKeepsOriginalCurrencyAndHKD() {
        let transaction = TransactionRecord(
            date: Date(timeIntervalSince1970: 0),
            merchant: "Amazon JP",
            categoryName: "online",
            cardID: UUID(),
            hkdAmount: Decimal(442),
            originalAmount: Decimal(8500),
            originalCurrencyCode: "JPY",
            exchangeRateToHKD: Decimal(string: "0.052")!,
            note: "travel adapter"
        )

        XCTAssertEqual(transaction.originalCurrencyCode, "JPY")
        XCTAssertEqual(transaction.hkdAmount, Decimal(442))
    }
}
```

- [ ] **Step 2: Run test and verify failure**

Run:

```bash
xcodebuild test -scheme CreditCardRecord -destination 'platform=iOS Simulator,name=iPhone 15' -only-testing:CreditCardRecordTests/ModelTests
```

Expected: FAIL because `TransactionRecord` does not exist.

- [ ] **Step 3: Add models**

Create `CreditCardRecord/Models/Transaction.swift`:

```swift
import Foundation
import SwiftData

@Model
final class TransactionRecord {
    @Attribute(.unique) var id: UUID
    var date: Date
    var merchant: String
    var categoryName: String
    var cardID: UUID?
    var hkdAmount: Decimal
    var originalAmount: Decimal?
    var originalCurrencyCode: String?
    var exchangeRateToHKD: Decimal?
    var note: String

    init(date: Date, merchant: String, categoryName: String, cardID: UUID?, hkdAmount: Decimal, originalAmount: Decimal? = nil, originalCurrencyCode: String? = nil, exchangeRateToHKD: Decimal? = nil, note: String = "") {
        self.id = UUID()
        self.date = date
        self.merchant = merchant
        self.categoryName = categoryName
        self.cardID = cardID
        self.hkdAmount = hkdAmount
        self.originalAmount = originalAmount
        self.originalCurrencyCode = originalCurrencyCode
        self.exchangeRateToHKD = exchangeRateToHKD
        self.note = note
    }
}
```

Create `CreditCardRecord/Models/CreditCard.swift`:

```swift
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
```

Create `CreditCardRecord/Models/StatementCycle.swift`:

```swift
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
```

Create `CreditCardRecord/Models/SpendingCategory.swift`:

```swift
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
```

- [ ] **Step 4: Run tests and commit**

Run:

```bash
xcodebuild test -scheme CreditCardRecord -destination 'platform=iOS Simulator,name=iPhone 15' -only-testing:CreditCardRecordTests/ModelTests
```

Expected: PASS.

Commit:

```bash
git add CreditCardRecord/Models CreditCardRecordTests/ModelTests.swift
git commit -m "feat: add spending domain models"
```

---

### Task 3: Implement Currency Conversion

**Files:**
- Create: `CreditCardRecord/Core/CurrencyConverter.swift`
- Test: `CreditCardRecordTests/CurrencyConverterTests.swift`

- [ ] **Step 1: Write failing tests**

Create `CreditCardRecordTests/CurrencyConverterTests.swift`:

```swift
import XCTest
@testable import CreditCardRecord

final class CurrencyConverterTests: XCTestCase {
    func testConvertsAssistCurrencyToHKD() throws {
        let hkd = try CurrencyConverter.convertToHKD(amount: Decimal(8500), rateToHKD: Decimal(string: "0.052")!)
        XCTAssertEqual(hkd, Decimal(442))
    }

    func testRejectsZeroRate() {
        XCTAssertThrowsError(try CurrencyConverter.convertToHKD(amount: Decimal(10), rateToHKD: Decimal(0)))
    }
}
```

- [ ] **Step 2: Run test and verify failure**

Run:

```bash
xcodebuild test -scheme CreditCardRecord -destination 'platform=iOS Simulator,name=iPhone 15' -only-testing:CreditCardRecordTests/CurrencyConverterTests
```

Expected: FAIL because `CurrencyConverter` does not exist.

- [ ] **Step 3: Add converter**

Create `CreditCardRecord/Core/CurrencyConverter.swift`:

```swift
import Foundation

enum CurrencyConversionError: Error, Equatable {
    case invalidRate
}

enum CurrencyConverter {
    static func convertToHKD(amount: Decimal, rateToHKD: Decimal) throws -> Decimal {
        guard rateToHKD > 0 else { throw CurrencyConversionError.invalidRate }
        return amount * rateToHKD
    }
}
```

- [ ] **Step 4: Run tests and commit**

Run:

```bash
xcodebuild test -scheme CreditCardRecord -destination 'platform=iOS Simulator,name=iPhone 15' -only-testing:CreditCardRecordTests/CurrencyConverterTests
```

Expected: PASS.

Commit:

```bash
git add CreditCardRecord/Core/CurrencyConverter.swift CreditCardRecordTests/CurrencyConverterTests.swift
git commit -m "feat: add HKD currency conversion"
```

---

### Task 4: Implement Statement Cycle Prediction

**Files:**
- Create: `CreditCardRecord/Core/StatementCyclePredictor.swift`
- Test: `CreditCardRecordTests/StatementCyclePredictorTests.swift`

- [ ] **Step 1: Write failing tests**

Create `CreditCardRecordTests/StatementCyclePredictorTests.swift`:

```swift
import XCTest
@testable import CreditCardRecord

final class StatementCyclePredictorTests: XCTestCase {
    func testPredictsFixedDueDayNextMonth() throws {
        let calendar = Calendar(identifier: .gregorian)
        let firstStatement = calendar.date(from: DateComponents(year: 2026, month: 6, day: 12))!
        let cycle = StatementCyclePredictor.predictNextCycle(
            previousStatementDate: firstStatement,
            statementDay: 12,
            dueRuleKind: .fixedDayOfMonth,
            dueDayOrOffset: 5,
            calendar: calendar
        )

        XCTAssertEqual(calendar.component(.day, from: cycle.statementDate), 12)
        XCTAssertEqual(calendar.component(.month, from: cycle.statementDate), 7)
        XCTAssertEqual(calendar.component(.day, from: cycle.dueDate), 5)
        XCTAssertEqual(calendar.component(.month, from: cycle.dueDate), 8)
    }

    func testPredictsOffsetDueDate() {
        let calendar = Calendar(identifier: .gregorian)
        let firstStatement = calendar.date(from: DateComponents(year: 2026, month: 6, day: 12))!
        let cycle = StatementCyclePredictor.predictNextCycle(
            previousStatementDate: firstStatement,
            statementDay: 12,
            dueRuleKind: .daysAfterStatement,
            dueDayOrOffset: 25,
            calendar: calendar
        )

        XCTAssertEqual(calendar.component(.day, from: cycle.dueDate), 7)
        XCTAssertEqual(calendar.component(.month, from: cycle.dueDate), 7)
    }
}
```

- [ ] **Step 2: Run test and verify failure**

Run:

```bash
xcodebuild test -scheme CreditCardRecord -destination 'platform=iOS Simulator,name=iPhone 15' -only-testing:CreditCardRecordTests/StatementCyclePredictorTests
```

Expected: FAIL because `StatementCyclePredictor` does not exist.

- [ ] **Step 3: Add predictor**

Create `CreditCardRecord/Core/StatementCyclePredictor.swift`:

```swift
import Foundation

struct PredictedCycle: Equatable {
    let startDate: Date
    let endDate: Date
    let statementDate: Date
    let dueDate: Date
}

enum StatementCyclePredictor {
    static func predictNextCycle(previousStatementDate: Date, statementDay: Int, dueRuleKind: DueRuleKind, dueDayOrOffset: Int, calendar: Calendar = .current) -> PredictedCycle {
        let nextStatement = dateBySetting(day: statementDay, monthsAfter: 1, from: previousStatementDate, calendar: calendar)
        let startDate = calendar.date(byAdding: .day, value: 1, to: previousStatementDate)!
        let endDate = nextStatement

        let dueDate: Date
        switch dueRuleKind {
        case .fixedDayOfMonth:
            dueDate = dateBySetting(day: dueDayOrOffset, monthsAfter: 1, from: nextStatement, calendar: calendar)
        case .daysAfterStatement:
            dueDate = calendar.date(byAdding: .day, value: dueDayOrOffset, to: nextStatement)!
        }

        return PredictedCycle(startDate: startDate, endDate: endDate, statementDate: nextStatement, dueDate: dueDate)
    }

    private static func dateBySetting(day: Int, monthsAfter: Int, from date: Date, calendar: Calendar) -> Date {
        let shifted = calendar.date(byAdding: .month, value: monthsAfter, to: date)!
        var components = calendar.dateComponents([.year, .month], from: shifted)
        let range = calendar.range(of: .day, in: .month, for: shifted)!
        components.day = min(max(day, 1), range.count)
        return calendar.date(from: components)!
    }
}
```

- [ ] **Step 4: Run tests and commit**

Run:

```bash
xcodebuild test -scheme CreditCardRecord -destination 'platform=iOS Simulator,name=iPhone 15' -only-testing:CreditCardRecordTests/StatementCyclePredictorTests
```

Expected: PASS.

Commit:

```bash
git add CreditCardRecord/Core/StatementCyclePredictor.swift CreditCardRecordTests/StatementCyclePredictorTests.swift
git commit -m "feat: predict statement cycles"
```

---

### Task 5: Implement Repayment Calculator

**Files:**
- Create: `CreditCardRecord/Core/RepaymentCalculator.swift`
- Test: `CreditCardRecordTests/RepaymentCalculatorTests.swift`

- [ ] **Step 1: Write failing test**

Create `CreditCardRecordTests/RepaymentCalculatorTests.swift`:

```swift
import XCTest
@testable import CreditCardRecord

final class RepaymentCalculatorTests: XCTestCase {
    func testSumsTransactionsInsideCycleForCardOnly() {
        let calendar = Calendar(identifier: .gregorian)
        let cardID = UUID()
        let otherCardID = UUID()
        let cycle = RepaymentWindow(
            cardID: cardID,
            startDate: calendar.date(from: DateComponents(year: 2026, month: 6, day: 13))!,
            endDate: calendar.date(from: DateComponents(year: 2026, month: 7, day: 12))!
        )
        let transactions = [
            TransactionRecord(date: calendar.date(from: DateComponents(year: 2026, month: 6, day: 20))!, merchant: "Cafe", categoryName: "dining", cardID: cardID, hkdAmount: Decimal(58)),
            TransactionRecord(date: calendar.date(from: DateComponents(year: 2026, month: 7, day: 1))!, merchant: "MTR", categoryName: "transport", cardID: cardID, hkdAmount: Decimal(120)),
            TransactionRecord(date: calendar.date(from: DateComponents(year: 2026, month: 7, day: 1))!, merchant: "Shop", categoryName: "shopping", cardID: otherCardID, hkdAmount: Decimal(999))
        ]

        XCTAssertEqual(RepaymentCalculator.totalDue(for: cycle, transactions: transactions), Decimal(178))
    }
}
```

- [ ] **Step 2: Run test and verify failure**

Run:

```bash
xcodebuild test -scheme CreditCardRecord -destination 'platform=iOS Simulator,name=iPhone 15' -only-testing:CreditCardRecordTests/RepaymentCalculatorTests
```

Expected: FAIL because `RepaymentCalculator` does not exist.

- [ ] **Step 3: Add calculator**

Create `CreditCardRecord/Core/RepaymentCalculator.swift`:

```swift
import Foundation

struct RepaymentWindow {
    let cardID: UUID
    let startDate: Date
    let endDate: Date
}

enum RepaymentCalculator {
    static func totalDue(for window: RepaymentWindow, transactions: [TransactionRecord]) -> Decimal {
        transactions
            .filter { $0.cardID == window.cardID && $0.date >= window.startDate && $0.date <= window.endDate }
            .reduce(Decimal(0)) { $0 + $1.hkdAmount }
    }
}
```

- [ ] **Step 4: Run tests and commit**

Run:

```bash
xcodebuild test -scheme CreditCardRecord -destination 'platform=iOS Simulator,name=iPhone 15' -only-testing:CreditCardRecordTests/RepaymentCalculatorTests
```

Expected: PASS.

Commit:

```bash
git add CreditCardRecord/Core/RepaymentCalculator.swift CreditCardRecordTests/RepaymentCalculatorTests.swift
git commit -m "feat: calculate repayment totals"
```

---

### Task 6: Build Quick Add Foundation UI

**Files:**
- Create: `CreditCardRecord/Features/QuickAdd/QuickAddView.swift`
- Modify: `CreditCardRecord/ContentView.swift`
- UI Test: `CreditCardRecordUITests/QuickAddUITests.swift`

- [ ] **Step 1: Write failing UI test**

Create `CreditCardRecordUITests/QuickAddUITests.swift`:

```swift
import XCTest

final class QuickAddUITests: XCTestCase {
    func testQuickAddScreenShowsCoreFields() {
        let app = XCUIApplication()
        app.launch()

        XCTAssertTrue(app.staticTexts["Quick Add"].exists)
        XCTAssertTrue(app.textFields["Amount"].exists)
        XCTAssertTrue(app.textFields["Merchant"].exists)
        XCTAssertTrue(app.buttons["Save Transaction"].exists)
    }
}
```

- [ ] **Step 2: Run UI test and verify failure**

Run:

```bash
xcodebuild test -scheme CreditCardRecord -destination 'platform=iOS Simulator,name=iPhone 15' -only-testing:CreditCardRecordUITests/QuickAddUITests
```

Expected: FAIL because Quick Add fields are missing.

- [ ] **Step 3: Add Quick Add view**

Create `CreditCardRecord/Features/QuickAdd/QuickAddView.swift`:

```swift
import SwiftUI
import SwiftData

struct QuickAddView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var cards: [CreditCard]
    @State private var amount = ""
    @State private var merchant = ""
    @State private var categoryName = "dining"
    @State private var selectedCardID: UUID?

    private let categories = ["dining", "transport", "grocery", "shopping", "bills", "entertainment", "travel", "online", "health", "education", "other"]

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    TabView(selection: $selectedCardID) {
                        ForEach(cards) { card in
                            VStack(alignment: .leading) {
                                Text(card.displayName).font(.headline)
                                Text("**** \(card.last4)").font(.subheadline)
                            }
                            .frame(maxWidth: .infinity, minHeight: 120)
                            .background(.thinMaterial)
                            .clipShape(RoundedRectangle(cornerRadius: 14))
                            .tag(Optional(card.id))
                        }
                    }
                    .frame(height: 150)
                    .tabViewStyle(.page)
                }

                Section("Transaction") {
                    TextField("Amount", text: $amount)
                        .keyboardType(.decimalPad)
                    TextField("Merchant", text: $merchant)
                    Picker("Category", selection: $categoryName) {
                        ForEach(categories, id: \.self) { Text($0).tag($0) }
                    }
                }

                Button("Save Transaction") {
                    saveTransaction()
                }
                .disabled(Decimal(string: amount) == nil || merchant.isEmpty)
            }
            .navigationTitle("Quick Add")
        }
    }

    private func saveTransaction() {
        guard let hkdAmount = Decimal(string: amount) else { return }
        let record = TransactionRecord(date: Date(), merchant: merchant, categoryName: categoryName, cardID: selectedCardID ?? cards.first?.id, hkdAmount: hkdAmount)
        modelContext.insert(record)
        amount = ""
        merchant = ""
    }
}
```

Modify `CreditCardRecord/ContentView.swift`:

```swift
import SwiftUI

struct ContentView: View {
    var body: some View {
        TabView {
            QuickAddView()
                .tabItem { Label("Quick", systemImage: "plus.circle") }
            RepaymentView()
                .tabItem { Label("Repayment", systemImage: "creditcard") }
            Text("Charts")
                .tabItem { Label("Charts", systemImage: "chart.pie") }
            Text("Cards")
                .tabItem { Label("Cards", systemImage: "rectangle.stack") }
            Text("Settings")
                .tabItem { Label("Settings", systemImage: "gearshape") }
        }
    }
}
```

Create initial `CreditCardRecord/Features/Repayment/RepaymentView.swift`:

```swift
import SwiftUI

struct RepaymentView: View {
    var body: some View {
        NavigationStack {
            Text("No repayments yet")
                .navigationTitle("Repayment")
        }
    }
}
```

- [ ] **Step 4: Run UI test and commit**

Run:

```bash
xcodebuild test -scheme CreditCardRecord -destination 'platform=iOS Simulator,name=iPhone 15' -only-testing:CreditCardRecordUITests/QuickAddUITests
```

Expected: PASS.

Commit:

```bash
git add CreditCardRecord/ContentView.swift CreditCardRecord/Features CreditCardRecordUITests/QuickAddUITests.swift
git commit -m "feat: add quick transaction entry"
```

---

### Task 7: Add Repayment Screen

**Files:**
- Modify: `CreditCardRecord/Features/Repayment/RepaymentView.swift`
- UI Test: `CreditCardRecordUITests/RepaymentUITests.swift`

- [ ] **Step 1: Write failing UI test**

Create `CreditCardRecordUITests/RepaymentUITests.swift`:

```swift
import XCTest

final class RepaymentUITests: XCTestCase {
    func testRepaymentTabExists() {
        let app = XCUIApplication()
        app.launch()
        app.tabBars.buttons["Repayment"].tap()
        XCTAssertTrue(app.navigationBars["Repayment"].exists)
        XCTAssertTrue(app.staticTexts["Next Payment Due"].exists)
    }
}
```

- [ ] **Step 2: Run test and verify failure**

Run:

```bash
xcodebuild test -scheme CreditCardRecord -destination 'platform=iOS Simulator,name=iPhone 15' -only-testing:CreditCardRecordUITests/RepaymentUITests
```

Expected: FAIL because "Next Payment Due" is missing.

- [ ] **Step 3: Add repayment overview**

Replace `CreditCardRecord/Features/Repayment/RepaymentView.swift`:

```swift
import SwiftUI
import SwiftData

struct RepaymentView: View {
    @Query private var cards: [CreditCard]

    var body: some View {
        NavigationStack {
            List {
                Section("Next Payment Due") {
                    if cards.isEmpty {
                        Text("Add a card to start tracking repayment")
                    } else {
                        ForEach(cards) { card in
                            VStack(alignment: .leading, spacing: 4) {
                                Text(card.displayName).font(.headline)
                                Text("Statement day \(card.statementDay)")
                                Text("Due rule \(card.dueRuleKindRaw) \(card.dueDayOrOffset)")
                            }
                        }
                    }
                }
            }
            .navigationTitle("Repayment")
        }
    }
}
```

- [ ] **Step 4: Run UI test and commit**

Run:

```bash
xcodebuild test -scheme CreditCardRecord -destination 'platform=iOS Simulator,name=iPhone 15' -only-testing:CreditCardRecordUITests/RepaymentUITests
```

Expected: PASS.

Commit:

```bash
git add CreditCardRecord/Features/Repayment/RepaymentView.swift CreditCardRecordUITests/RepaymentUITests.swift
git commit -m "feat: add repayment overview"
```

---

### Task 8: Add Backup Envelope Service

**Files:**
- Create: `CreditCardRecord/Core/BackupEnvelope.swift`
- Test: `CreditCardRecordTests/BackupEnvelopeTests.swift`

- [ ] **Step 1: Write failing tests**

Create `CreditCardRecordTests/BackupEnvelopeTests.swift`:

```swift
import XCTest
@testable import CreditCardRecord

final class BackupEnvelopeTests: XCTestCase {
    func testEncryptDecryptRoundTrip() throws {
        let payload = Data("hello backup".utf8)
        let envelope = try BackupEnvelope.encrypt(payload: payload, password: "correct horse battery staple")
        let decrypted = try BackupEnvelope.decrypt(envelope: envelope, password: "correct horse battery staple")
        XCTAssertEqual(decrypted, payload)
    }

    func testWrongPasswordFails() throws {
        let envelope = try BackupEnvelope.encrypt(payload: Data("secret".utf8), password: "right")
        XCTAssertThrowsError(try BackupEnvelope.decrypt(envelope: envelope, password: "wrong"))
    }
}
```

- [ ] **Step 2: Run test and verify failure**

Run:

```bash
xcodebuild test -scheme CreditCardRecord -destination 'platform=iOS Simulator,name=iPhone 15' -only-testing:CreditCardRecordTests/BackupEnvelopeTests
```

Expected: FAIL because `BackupEnvelope` does not exist.

- [ ] **Step 3: Add CryptoKit envelope**

Create `CreditCardRecord/Core/BackupEnvelope.swift`:

```swift
import CryptoKit
import Foundation

struct EncryptedBackup: Codable, Equatable {
    let version: Int
    let salt: Data
    let nonce: Data
    let ciphertext: Data
    let tag: Data
}

enum BackupEnvelope {
    static func encrypt(payload: Data, password: String) throws -> EncryptedBackup {
        let salt = randomData(count: 16)
        let key = SymmetricKey(data: SHA256.hash(data: Data(password.utf8) + salt))
        let sealed = try AES.GCM.seal(payload, using: key)
        return EncryptedBackup(version: 1, salt: salt, nonce: sealed.nonce.withUnsafeBytes { Data($0) }, ciphertext: sealed.ciphertext, tag: sealed.tag)
    }

    static func decrypt(envelope: EncryptedBackup, password: String) throws -> Data {
        let key = SymmetricKey(data: SHA256.hash(data: Data(password.utf8) + envelope.salt))
        let nonce = try AES.GCM.Nonce(data: envelope.nonce)
        let box = try AES.GCM.SealedBox(nonce: nonce, ciphertext: envelope.ciphertext, tag: envelope.tag)
        return try AES.GCM.open(box, using: key)
    }

    private static func randomData(count: Int) -> Data {
        var bytes = [UInt8](repeating: 0, count: count)
        _ = SecRandomCopyBytes(kSecRandomDefault, bytes.count, &bytes)
        return Data(bytes)
    }
}
```

- [ ] **Step 4: Run tests and commit**

Run:

```bash
xcodebuild test -scheme CreditCardRecord -destination 'platform=iOS Simulator,name=iPhone 15' -only-testing:CreditCardRecordTests/BackupEnvelopeTests
```

Expected: PASS.

Commit:

```bash
git add CreditCardRecord/Core/BackupEnvelope.swift CreditCardRecordTests/BackupEnvelopeTests.swift
git commit -m "feat: add encrypted backup envelope"
```

---

### Task 9: Add Widget Snapshot Service

**Files:**
- Create: `CreditCardRecord/Core/WidgetSnapshot.swift`
- Test: `CreditCardRecordTests/WidgetSnapshotTests.swift`

- [ ] **Step 1: Write failing tests**

Create `CreditCardRecordTests/WidgetSnapshotTests.swift`:

```swift
import XCTest
@testable import CreditCardRecord

final class WidgetSnapshotTests: XCTestCase {
    func testSnapshotHidesAmountWhenPrivate() {
        let due = WidgetDuePayment(cardName: "HSBC Visa", amountHKD: Decimal(3280), dueDate: Date(timeIntervalSince1970: 0))
        let snapshot = WidgetSnapshotBuilder.displayLine(for: due, now: Date(timeIntervalSince1970: -86400), privateMode: true)
        XCTAssertFalse(snapshot.contains("3280"))
        XCTAssertTrue(snapshot.contains("HSBC Visa"))
    }
}
```

- [ ] **Step 2: Run test and verify failure**

Run:

```bash
xcodebuild test -scheme CreditCardRecord -destination 'platform=iOS Simulator,name=iPhone 15' -only-testing:CreditCardRecordTests/WidgetSnapshotTests
```

Expected: FAIL because widget snapshot types do not exist.

- [ ] **Step 3: Add snapshot builder**

Create `CreditCardRecord/Core/WidgetSnapshot.swift`:

```swift
import Foundation

struct WidgetDuePayment: Codable, Equatable {
    let cardName: String
    let amountHKD: Decimal
    let dueDate: Date
}

enum WidgetSnapshotBuilder {
    static func displayLine(for payment: WidgetDuePayment, now: Date, privateMode: Bool, calendar: Calendar = .current) -> String {
        let days = calendar.dateComponents([.day], from: calendar.startOfDay(for: now), to: calendar.startOfDay(for: payment.dueDate)).day ?? 0
        let amount = privateMode ? "" : " HK$\(payment.amountHKD)"
        return "\(payment.cardName)\(amount), due in \(max(days, 0)) day\(days == 1 ? "" : "s")"
    }
}
```

- [ ] **Step 4: Run tests and commit**

Run:

```bash
xcodebuild test -scheme CreditCardRecord -destination 'platform=iOS Simulator,name=iPhone 15' -only-testing:CreditCardRecordTests/WidgetSnapshotTests
```

Expected: PASS.

Commit:

```bash
git add CreditCardRecord/Core/WidgetSnapshot.swift CreditCardRecordTests/WidgetSnapshotTests.swift
git commit -m "feat: add widget payment snapshot"
```

---

### Task 10: Add Widget Extension

**Files:**
- Create: `CreditCardRecordWidget/CreditCardRecordWidget.swift`
- Modify: `CreditCardRecord.xcodeproj`

- [ ] **Step 1: Add widget target in Xcode**

Add target:

```text
File > New > Target > Widget Extension
Product Name: CreditCardRecordWidget
Include Configuration Intent: false
```

Enable App Groups for app and widget:

```text
group.com.local.CreditCardRecord
```

- [ ] **Step 2: Replace widget implementation**

Create `CreditCardRecordWidget/CreditCardRecordWidget.swift`:

```swift
import WidgetKit
import SwiftUI

struct PaymentEntry: TimelineEntry {
    let date: Date
    let line: String
}

struct Provider: TimelineProvider {
    func placeholder(in context: Context) -> PaymentEntry {
        PaymentEntry(date: Date(), line: "Next payment due")
    }

    func getSnapshot(in context: Context, completion: @escaping (PaymentEntry) -> Void) {
        completion(PaymentEntry(date: Date(), line: "HSBC Visa, due in 5 days"))
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<PaymentEntry>) -> Void) {
        let entry = PaymentEntry(date: Date(), line: "Open app to refresh payments")
        completion(Timeline(entries: [entry], policy: .after(Date().addingTimeInterval(3600))))
    }
}

struct CreditCardRecordWidgetEntryView: View {
    var entry: Provider.Entry

    var body: some View {
        VStack(alignment: .leading) {
            Text("Next Payment")
                .font(.caption)
            Text(entry.line)
                .font(.headline)
                .minimumScaleFactor(0.75)
        }
        .containerBackground(.background, for: .widget)
    }
}

@main
struct CreditCardRecordWidget: Widget {
    let kind = "CreditCardRecordWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: Provider()) { entry in
            CreditCardRecordWidgetEntryView(entry: entry)
        }
        .configurationDisplayName("Next Payment Due")
        .description("Shows the next credit card payment countdown.")
        .supportedFamilies([.systemSmall, .systemMedium])
    }
}
```

- [ ] **Step 3: Build and commit**

Run:

```bash
xcodebuild build -scheme CreditCardRecord -destination 'platform=iOS Simulator,name=iPhone 15'
```

Expected: BUILD SUCCEEDED.

Commit:

```bash
git add CreditCardRecord.xcodeproj CreditCardRecordWidget
git commit -m "feat: add next payment widget"
```

---

### Task 11: Add App Intent For Fast Capture

**Files:**
- Create: `CreditCardRecord/Intents/RecordSpendingIntent.swift`

- [ ] **Step 1: Add intent**

Create `CreditCardRecord/Intents/RecordSpendingIntent.swift`:

```swift
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
```

- [ ] **Step 2: Build and commit**

Run:

```bash
xcodebuild build -scheme CreditCardRecord -destination 'platform=iOS Simulator,name=iPhone 15'
```

Expected: BUILD SUCCEEDED.

Commit:

```bash
git add CreditCardRecord/Intents/RecordSpendingIntent.swift
git commit -m "feat: add shortcut entry intent"
```

---

### Task 12: Final Verification

**Files:**
- Modify: `README.md`

- [ ] **Step 1: Add README run instructions**

Create or update `README.md`:

```markdown
# Credit Card Record

Offline iOS app for Hong Kong credit card spending, repayment cycle tracking, simple due reminders, encrypted backup export/import, and a next-payment widget.

## Requirements

- Xcode 16 or newer
- iOS 17 simulator or device

## Build

```bash
xcodebuild build -scheme CreditCardRecord -destination 'platform=iOS Simulator,name=iPhone 15'
```

## Test

```bash
xcodebuild test -scheme CreditCardRecord -destination 'platform=iOS Simulator,name=iPhone 15'
```
```

- [ ] **Step 2: Run all tests**

Run:

```bash
xcodebuild test -scheme CreditCardRecord -destination 'platform=iOS Simulator,name=iPhone 15'
```

Expected: all tests PASS.

- [ ] **Step 3: Run app build**

Run:

```bash
xcodebuild build -scheme CreditCardRecord -destination 'platform=iOS Simulator,name=iPhone 15'
```

Expected: BUILD SUCCEEDED.

- [ ] **Step 4: Commit**

Commit:

```bash
git add README.md
git commit -m "docs: add build and test instructions"
```

---

## Self-Review

Spec coverage for this foundation plan:

- Offline native SwiftUI app: Tasks 1, 6, 7.
- SwiftData models: Task 2.
- Quick Add with card carousel: Task 6.
- HKD plus assist currency data and conversion logic: Tasks 2, 3, 6.
- Statement-cycle repayment prediction and totals: Tasks 4, 5, 7.
- Encrypted backup logic: Task 8.
- Widget countdown display logic and extension shell: Tasks 9, 10.
- App Intent for Action Button/Back Tap: Task 11.

Follow-up implementation plans, in order:

1. Card setup, card image picker, category management, and seed data.
2. Local notification scheduling UI, permission flow, and reminder tests.
3. Backup export/import screens using `BackupEnvelope`.
4. Charts using Swift Charts.
5. Smart card hints.
