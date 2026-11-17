import AppIntents
import SwiftData
import XCTest
@testable import CreditCardRecord

@MainActor
final class WalletImportTests: XCTestCase {
    private let now = Date(timeIntervalSince1970: 1_794_934_000)
    private var retainedContainer: ModelContainer?

    func testStoreConfigurationRetainsLegacyLocationAndDisablesCloud() {
        let previous = ModelConfiguration(schema: AppModelStore.schema)
        let current = AppModelStore.configuration()
        XCTAssertEqual(current.url, previous.url)
        XCTAssertNil(current.cloudKitContainerIdentifier)
        XCTAssertTrue(AppModelStore.configuration(inMemory: true).isStoredInMemoryOnly)
    }

    func testHKDPurchasePersistsWithSourceAndExactDecimal() throws {
        let (container, context, card) = try store()
        let result = try WalletImportRecorder.record(input(card, amount: 12.34), in: context, now: now)
        XCTAssertTrue(result.inserted)
        let saved = try XCTUnwrap(ModelContext(container).fetch(FetchDescriptor<TransactionRecord>()).first)
        XCTAssertEqual(saved.cardID, card.id)
        XCTAssertEqual(saved.merchant, "Cafe")
        XCTAssertEqual(saved.categoryName, "dining")
        XCTAssertEqual(saved.hkdAmount, Decimal(string: "12.34"))
        XCTAssertEqual(saved.originalAmount, saved.hkdAmount)
        XCTAssertEqual(saved.originalCurrencyCode, "HKD")
        XCTAssertEqual(saved.exchangeRateToHKD, 1)
        XCTAssertEqual(saved.date, now)
        XCTAssertEqual(saved.importSource, "shortcut")
        XCTAssertNil(saved.importReference)
    }

    func testForeignCurrencyRequiresRateWithoutChangingTheStore() throws {
        let (_, context, card) = try store()
        var purchase = input(card)
        purchase.currency = "TWD"
        for rate in [nil, Double(0), Double(-1), Double.nan, Double.infinity] {
            purchase.exchangeRateToHKD = rate
            XCTAssertThrowsError(try WalletImportRecorder.record(purchase, in: context, now: now)) {
                XCTAssertEqual($0 as? WalletImportError, .missingExchangeRate)
            }
        }
        XCTAssertEqual(try context.fetchCount(FetchDescriptor<TransactionRecord>()), 0)
    }

    func testForeignCurrencyPreservesOriginalAndConvertsOnlyWithExplicitRate() throws {
        let (_, context, card) = try store()
        let purchase = WalletImportInput(cardID: card.id, amount: 1000, merchant: "Taipei Cafe", currency: " twd ", exchangeRateToHKD: 0.24)
        let record = try WalletImportRecorder.record(purchase, in: context, now: now).record
        XCTAssertEqual(record.originalAmount, 1000)
        XCTAssertEqual(record.originalCurrencyCode, "TWD")
        XCTAssertEqual(record.hkdAmount, 240)
        XCTAssertEqual(record.exchangeRateToHKD, Decimal(string: "0.24"))
    }

    func testInvalidAmountMerchantCurrencyAndDateDoNotCreateRecords() throws {
        let (_, context, card) = try store()
        for amount in [0, -10, Double.nan, Double.infinity, Double.greatestFiniteMagnitude] {
            XCTAssertThrowsError(try WalletImportRecorder.record(input(card, amount: amount), in: context, now: now)) {
                XCTAssertEqual($0 as? WalletImportError, .invalidAmount)
            }
        }
        var purchase = input(card)
        purchase.merchant = " \n "
        assertError(.invalidMerchant, purchase, context)
        purchase = input(card)
        purchase.currency = "HKG"
        assertError(.invalidCurrency, purchase, context)
        purchase = input(card)
        purchase.date = now.addingTimeInterval(120)
        assertError(.invalidDate, purchase, context)
        XCTAssertEqual(try context.fetchCount(FetchDescriptor<TransactionRecord>()), 0)
    }

    func testRemovedOrInactiveCardNeverFallsBackToAnotherCard() throws {
        let (_, context, card) = try store()
        context.insert(makeCard("Other"))
        card.isActive = false
        try context.save()
        assertError(.missingCard, input(card), context)
        let purchase = input(card)
        context.delete(card)
        try context.save()
        assertError(.missingCard, purchase, context)
        XCTAssertEqual(try context.fetchCount(FetchDescriptor<TransactionRecord>()), 0)
    }

    func testReferenceDeduplicatesRetriesButIsScopedToTheSelectedCard() throws {
        let (_, context, card) = try store()
        var purchase = input(card)
        purchase.reference = " order-123 "
        let first = try WalletImportRecorder.record(purchase, in: context, now: now)
        let second = try WalletImportRecorder.record(purchase, in: context, now: now.addingTimeInterval(10))
        XCTAssertTrue(first.inserted)
        XCTAssertFalse(second.inserted)
        XCTAssertEqual(first.record.id, second.record.id)
        XCTAssertEqual(first.record.importReference, "order-123")
        let another = makeCard("Another")
        context.insert(another)
        purchase.cardID = another.id
        XCTAssertTrue(try WalletImportRecorder.record(purchase, in: context, now: now).inserted)
        XCTAssertEqual(try context.fetchCount(FetchDescriptor<TransactionRecord>()), 2)
    }

    func testConflictingReferenceDoesNotReplaceTheOriginalPurchase() throws {
        let (_, context, card) = try store()
        var purchase = input(card)
        purchase.reference = "same-reference"
        let original = try WalletImportRecorder.record(purchase, in: context, now: now).record
        purchase.amount = 999
        assertError(.referenceConflict, purchase, context)
        XCTAssertEqual(original.hkdAmount, 100)
        XCTAssertEqual(try context.fetchCount(FetchDescriptor<TransactionRecord>()), 1)
    }

    func testIdenticalPurchasesWithoutReferencesAreNotSilentlyDropped() throws {
        let (_, context, card) = try store()
        let first = try WalletImportRecorder.record(input(card), in: context, now: now)
        let second = try WalletImportRecorder.record(input(card), in: context, now: now)
        XCTAssertTrue(second.inserted)
        XCTAssertNotEqual(first.record.id, second.record.id)
        XCTAssertEqual(try context.fetchCount(FetchDescriptor<TransactionRecord>()), 2)
    }

    func testAppIntentMapsAllParametersAndSavesWithoutOpeningTheApp() throws {
        let (_, context, card) = try store()
        let intentCard = try XCTUnwrap(SpendingCardEntity.available(in: context).first)
        let intent = RecordSpendingIntent()
        intent.card = intentCard
        intent.amount = 88
        intent.merchant = "MTR"
        intent.currency = "HKD"
        intent.category = .transport
        intent.transactionDate = now
        intent.reference = "wallet-event-1"
        let record = try intent.record(in: context, now: now).record
        XCTAssertEqual(record.cardID, card.id)
        XCTAssertEqual(record.categoryName, "transport")
        XCTAssertEqual(record.date, now)
        XCTAssertEqual(record.importReference, "wallet-event-1")
        XCTAssertEqual(record.hkdAmount, 88)
        XCTAssertFalse(RecordSpendingIntent.openAppWhenRun)
        XCTAssertEqual(Set(SpendingShortcutCategory.allCases.map(\.rawValue)), Set(SpendingCategoryOption.allCases.map(\.rawValue)))
    }

    func testShortcutCardChoicesKeepIdentityAndExcludeInactiveCards() throws {
        let (_, context, card) = try store()
        let sameName = makeCard(card.displayName)
        sameName.last4 = "5678"
        context.insert(sameName)
        let inactive = makeCard("Inactive")
        inactive.isActive = false
        context.insert(inactive)
        try context.save()
        let choices = try SpendingCardEntity.available(in: context)
        XCTAssertEqual(choices.count, 2)
        XCTAssertEqual(Set(choices.map(\.id)), [card.id, sameName.id])
        XCTAssertEqual(Set(choices.map(\.last4)), ["1234", "5678"])
    }

    func testImportedPurchasesContributeToExistingConsumptionAnalytics() throws {
        let (_, context, card) = try store()
        _ = try WalletImportRecorder.record(input(card, amount: 50), in: context, now: now)
        _ = try WalletImportRecorder.record(input(card, amount: 25), in: context, now: now)
        let records = try context.fetch(FetchDescriptor<TransactionRecord>())
        XCTAssertEqual(ConsumptionAnalytics.records(from: records, cardID: card.id, month: now).reduce(0) { $0 + $1.hkdAmount }, 75)
    }

    private func store() throws -> (ModelContainer, ModelContext, CreditCard) {
        let container = try AppModelStore.makeContainer(inMemory: true)
        retainedContainer = container
        let context = container.mainContext
        let card = makeCard("HSBC Red")
        context.insert(card)
        try context.save()
        return (container, context, card)
    }

    private func makeCard(_ name: String) -> CreditCard {
        CreditCard(bankName: "HSBC", displayName: name, last4: "1234", statementDay: 15, dueRuleKind: .daysAfterStatement, dueDayOrOffset: 25)
    }

    private func input(_ card: CreditCard, amount: Double = 100) -> WalletImportInput {
        WalletImportInput(cardID: card.id, amount: amount, merchant: " Cafe ", currency: "hkd", category: "dining")
    }

    private func assertError(_ expected: WalletImportError, _ input: WalletImportInput, _ context: ModelContext, file: StaticString = #filePath, line: UInt = #line) {
        XCTAssertThrowsError(try WalletImportRecorder.record(input, in: context, now: now), file: file, line: line) {
            XCTAssertEqual($0 as? WalletImportError, expected, file: file, line: line)
        }
    }
}
