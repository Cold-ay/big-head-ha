import XCTest
import SwiftData
@testable import CreditCardRecord

final class ModelTests: XCTestCase {
    @MainActor
    func testTaiwanCardAndForeignCurrencyPersist() throws {
        let container = try ModelContainer(for: CreditCard.self, TransactionRecord.self,
                                           configurations: ModelConfiguration(isStoredInMemoryOnly: true))
        let context = ModelContext(container)
        let card = CreditCard(bankName: "玉山銀行", displayName: "Unicard", last4: "1234", statementDay: 15,
                              dueRuleKind: .daysAfterStatement, dueDayOrOffset: 15, billingCurrencyCode: "TWD", paymentKind: .credit)
        context.insert(card)
        context.insert(TransactionRecord(date: Date(), merchant: "Cafe", categoryName: "dining", cardID: card.id,
                                         hkdAmount: 240, originalAmount: 1000, originalCurrencyCode: "TWD", exchangeRateToHKD: Decimal(string: "0.24")))
        try context.save()
        let freshContext = ModelContext(container)
        XCTAssertEqual(try freshContext.fetch(FetchDescriptor<CreditCard>()).first?.currencyCode, "TWD")
        let saved = try XCTUnwrap(freshContext.fetch(FetchDescriptor<TransactionRecord>()).first)
        XCTAssertEqual(saved.originalAmount, 1000)
        XCTAssertEqual(saved.hkdAmount, 240)
        XCTAssertEqual(saved.originalCurrencyCode, "TWD")
    }

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

    func testAppLanguageChoicesIncludeChineseVariants() {
        XCTAssertEqual(AppLanguage.allCases.map(\.rawValue), ["system", "zh-Hant", "zh-Hans"])
        XCTAssertEqual(AppLanguage.traditionalChinese.title, "繁體中文")
        XCTAssertEqual(AppLanguage.simplifiedChinese.title, "简体中文")
    }

    func testAppLanguageLocaleIdentifiers() {
        XCTAssertNil(AppLanguage.system.localeIdentifier)
        XCTAssertEqual(AppLanguage.traditionalChinese.localeIdentifier, "zh-Hant-HK")
        XCTAssertEqual(AppLanguage.simplifiedChinese.localeIdentifier, "zh-Hans-CN")
    }

    func testAppStringsTranslateCoreComponentLabels() {
        XCTAssertEqual(AppStrings(language: .traditionalChinese).quickAddTitle, "快速新增")
        XCTAssertEqual(AppStrings(language: .simplifiedChinese).quickAddTitle, "快速添加")
        XCTAssertEqual(AppStrings(language: .traditionalChinese).repaymentStrategyTitle, "還款策略")
        XCTAssertEqual(AppStrings(language: .simplifiedChinese).repaymentStrategyTitle, "还款策略")
        XCTAssertEqual(AppStrings(language: .traditionalChinese).categoryDisplayName(for: "dining"), "餐飲")
        XCTAssertEqual(AppStrings(language: .simplifiedChinese).categoryDisplayName(for: "dining"), "餐饮")
    }

    func testRecurringDeductionGeneratesDueMonthlyTransactions() {
        let calendar = Calendar(identifier: .gregorian)
        let cardID = UUID()
        let rule = RecurringDeduction(
            cardID: cardID,
            merchant: "Netflix",
            categoryName: "entertainment",
            hkdAmount: Decimal(88),
            monthlyDay: 15,
            startDate: date(year: 2026, month: 1, day: 1, calendar: calendar)
        )

        let transactions = RecurringDeductionGenerator.transactionsToCreate(
            for: rule,
            existingTransactions: [],
            today: date(year: 2026, month: 3, day: 20, calendar: calendar),
            calendar: calendar
        )

        XCTAssertEqual(transactions.map(\.recurringYearMonth), ["2026-01", "2026-02", "2026-03"])
        XCTAssertEqual(transactions.map(\.date), [
            date(year: 2026, month: 1, day: 15, calendar: calendar),
            date(year: 2026, month: 2, day: 15, calendar: calendar),
            date(year: 2026, month: 3, day: 15, calendar: calendar)
        ])
        XCTAssertTrue(transactions.allSatisfy { $0.cardID == cardID && $0.merchant == "Netflix" })
    }

    func testRecurringDeductionClampsDayAndRespectsEndDate() {
        let calendar = Calendar(identifier: .gregorian)
        let rule = RecurringDeduction(
            cardID: UUID(),
            merchant: "Insurance",
            categoryName: "bills",
            hkdAmount: Decimal(300),
            monthlyDay: 31,
            startDate: date(year: 2026, month: 1, day: 1, calendar: calendar),
            endDate: date(year: 2026, month: 2, day: 28, calendar: calendar)
        )

        let transactions = RecurringDeductionGenerator.transactionsToCreate(
            for: rule,
            existingTransactions: [],
            today: date(year: 2026, month: 4, day: 10, calendar: calendar),
            calendar: calendar
        )

        XCTAssertEqual(transactions.map(\.recurringYearMonth), ["2026-01", "2026-02"])
        XCTAssertEqual(transactions.map(\.date), [
            date(year: 2026, month: 1, day: 31, calendar: calendar),
            date(year: 2026, month: 2, day: 28, calendar: calendar)
        ])
    }

    func testRecurringDeductionSkipsExistingGeneratedMonth() {
        let calendar = Calendar(identifier: .gregorian)
        let cardID = UUID()
        let rule = RecurringDeduction(
            cardID: cardID,
            merchant: "Gym",
            categoryName: "health",
            hkdAmount: Decimal(480),
            monthlyDay: 5,
            startDate: date(year: 2026, month: 1, day: 1, calendar: calendar)
        )
        let existing = TransactionRecord(
            date: date(year: 2026, month: 2, day: 5, calendar: calendar),
            merchant: "Gym",
            categoryName: "health",
            cardID: cardID,
            hkdAmount: Decimal(480),
            recurringDeductionID: rule.id,
            recurringYearMonth: "2026-02"
        )

        let transactions = RecurringDeductionGenerator.transactionsToCreate(
            for: rule,
            existingTransactions: [existing],
            today: date(year: 2026, month: 2, day: 20, calendar: calendar),
            calendar: calendar
        )

        XCTAssertEqual(transactions.map(\.recurringYearMonth), ["2026-01"])
    }

    private func date(year: Int, month: Int, day: Int, calendar: Calendar) -> Date {
        calendar.date(from: DateComponents(year: year, month: month, day: day))!
    }
}
