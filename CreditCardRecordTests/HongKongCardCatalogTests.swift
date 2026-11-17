import XCTest
import UIKit
@testable import CreditCardRecord

final class HongKongCardCatalogTests: XCTestCase {
    func testBundledCardArtworkMatchesCatalogAndDecodesOffline() {
        XCTAssertEqual(CardArtworkCatalog.sources.count, 20)
        XCTAssertEqual(Set(CardArtworkCatalog.sources.map(\.id)).count, CardArtworkCatalog.sources.count)
        for source in CardArtworkCatalog.sources {
            XCTAssertNotNil(CardCatalog.preset(id: source.id), source.id)
            XCTAssertEqual(source.url.scheme, "https")
            XCTAssertEqual(source.page.scheme, "https")
            let image = CardArtworkCatalog.image(for: source.id)
            XCTAssertNotNil(image?.cgImage, source.file)
            XCTAssertGreaterThan(image?.size.width ?? 0, 100, source.file)
            XCTAssertGreaterThan(source.displayRect.width, 0)
            XCTAssertLessThanOrEqual(source.displayRect.maxX, 1.001)
            XCTAssertLessThanOrEqual(source.displayRect.maxY, 1.001)
        }
        XCTAssertNil(CardArtworkCatalog.image(for: "manual-card"))
        XCTAssertNil(CardArtworkCatalog.image(for: nil))
    }

    func testTaiwanCatalogIncludesCreditCardsAndEasyCard() {
        XCTAssertEqual(CardCatalog.issuerNames(in: .taiwan).count, 10)
        XCTAssertEqual(CardCatalog.taiwanPresets.count, 16)
        XCTAssertEqual(CardCatalog.taiwanPresets.filter { $0.kind == .credit }.count, 15)
        XCTAssertTrue(CardCatalog.taiwanPresets.allSatisfy { $0.currencyCode == "TWD" && $0.sourceURL?.scheme == "https" })
        XCTAssertEqual(CardCatalog.preset(id: "tw-easycard")?.kind, .storedValue)
        XCTAssertEqual(CardCatalog.preset(id: "tw-taishin-richart")?.displayName, "台新Richart卡")
        XCTAssertEqual(Set(CardCatalog.allPresets.map(\.id)).count, CardCatalog.allPresets.count)
    }

    func testEveryIssuerHasAnOfficialSourceAndMarketsStaySeparate() {
        XCTAssertTrue(CardCatalog.allPresets.allSatisfy { $0.sourceURL?.host != nil })
        XCTAssertTrue(CardCatalog.presets(in: .hongKong).allSatisfy { $0.market == .hongKong && $0.currencyCode == "HKD" })
    }

    func testLegacyDebitAndStoredValueCardsDoNotRequireRepayment() {
        for id in ["za-card", "mox-card", "octopus-card", "tw-easycard"] {
            let card = CreditCard(bankName: "Legacy", displayName: id, last4: "1234", cardImageFileName: id,
                                  statementDay: 15, dueRuleKind: .daysAfterStatement, dueDayOrOffset: 25)
            XCTAssertFalse(card.requiresRepayment)
        }
        let credit = CreditCard(bankName: "Mox", displayName: "Credit", last4: "1234", cardImageFileName: "mox-credit",
                                statementDay: 15, dueRuleKind: .daysAfterStatement, dueDayOrOffset: 25)
        XCTAssertTrue(credit.requiresRepayment)
        credit.isActive = false
        XCTAssertFalse(credit.requiresRepayment)
    }

    func testTaiwanCardRetainsBillingCurrency() {
        let card = CreditCard(bankName: "玉山銀行", displayName: "Unicard", last4: "1234", cardImageFileName: "tw-esun-unicard",
                              statementDay: 15, dueRuleKind: .daysAfterStatement, dueDayOrOffset: 15)
        XCTAssertEqual(card.currencyCode, "TWD")
    }

    func testCatalogContainsCommonHongKongIssuers() {
        let issuers = Set(HongKongCardCatalog.presets.map(\.issuerName))

        XCTAssertTrue(issuers.contains("HSBC"))
        XCTAssertTrue(issuers.contains("Hang Seng Bank"))
        XCTAssertTrue(issuers.contains("Bank of China Hong Kong"))
        XCTAssertTrue(issuers.contains("AEON Credit Service"))
    }

    func testEveryPresetHasDueRuleDefaults() {
        XCTAssertFalse(HongKongCardCatalog.presets.isEmpty)
        XCTAssertTrue(HongKongCardCatalog.presets.allSatisfy { $0.defaultStatementDay >= 1 && $0.defaultStatementDay <= 31 })
        XCTAssertTrue(HongKongCardCatalog.presets.allSatisfy { $0.defaultDueOffsetDays >= 1 })
    }

    func testIssuerNamesAreUniqueAndSortedByCatalogOrder() {
        XCTAssertEqual(Array(HongKongCardCatalog.issuerNames.prefix(3)), ["HSBC", "Hang Seng Bank", "Standard Chartered"])
        XCTAssertEqual(Set(HongKongCardCatalog.issuerNames).count, HongKongCardCatalog.issuerNames.count)
    }

    func testPresetsCanBeFilteredByIssuer() {
        let hsbcPresets = HongKongCardCatalog.presets(for: "HSBC")

        XCTAssertFalse(hsbcPresets.isEmpty)
        XCTAssertTrue(hsbcPresets.allSatisfy { $0.issuerName == "HSBC" })
    }

    func testCatalogContainsVirtualBankAndOctopusPresets() {
        XCTAssertEqual(
            HongKongCardCatalog.presets(for: "ZA Bank").map(\.displayName),
            ["ZA Card"]
        )
        XCTAssertEqual(
            HongKongCardCatalog.presets(for: "Mox Bank").map(\.displayName),
            ["Mox Credit", "Mox Card"]
        )
        XCTAssertEqual(
            HongKongCardCatalog.presets(for: "Octopus").map(\.displayName),
            ["Octopus Card"]
        )
    }

    func testDefaultPresetUsesFirstCardForIssuer() {
        XCTAssertEqual(HongKongCardCatalog.defaultPreset(for: "HSBC")?.id, "hsbc-red")
        XCTAssertNil(HongKongCardCatalog.defaultPreset(for: "Unknown Bank"))
    }

    func testCardRemovalSummaryCountsLinkedTransactions() {
        let card = CreditCard(bankName: "HSBC", displayName: "HSBC Red", last4: "1234", statementDay: 15, dueRuleKind: .daysAfterStatement, dueDayOrOffset: 25)
        let otherCardID = UUID()
        let transactions = [
            TransactionRecord(date: Date(timeIntervalSince1970: 0), merchant: "Cafe", categoryName: "dining", cardID: card.id, hkdAmount: Decimal(88)),
            TransactionRecord(date: Date(timeIntervalSince1970: 0), merchant: "MTR", categoryName: "transport", cardID: otherCardID, hkdAmount: Decimal(12)),
            TransactionRecord(date: Date(timeIntervalSince1970: 0), merchant: "Lunch", categoryName: "dining", cardID: card.id, hkdAmount: Decimal(52))
        ]

        XCTAssertEqual(CardRemovalSummary.linkedTransactionCount(for: card, in: transactions), 2)
    }

    func testCardRemovalSummaryCountsLinkedStatementCycles() {
        let card = CreditCard(bankName: "HSBC", displayName: "HSBC Red", last4: "1234", statementDay: 15, dueRuleKind: .daysAfterStatement, dueDayOrOffset: 25)
        let otherCard = CreditCard(bankName: "Mox Bank", displayName: "Mox Credit", last4: "5678", statementDay: 15, dueRuleKind: .daysAfterStatement, dueDayOrOffset: 25)
        let cycles = [
            StatementCycle(cardID: card.id, startDate: Date(timeIntervalSince1970: 0), endDate: Date(timeIntervalSince1970: 100), statementDate: Date(timeIntervalSince1970: 100), dueDate: Date(timeIntervalSince1970: 200)),
            StatementCycle(cardID: otherCard.id, startDate: Date(timeIntervalSince1970: 0), endDate: Date(timeIntervalSince1970: 100), statementDate: Date(timeIntervalSince1970: 100), dueDate: Date(timeIntervalSince1970: 200)),
            StatementCycle(cardID: card.id, startDate: Date(timeIntervalSince1970: 300), endDate: Date(timeIntervalSince1970: 400), statementDate: Date(timeIntervalSince1970: 400), dueDate: Date(timeIntervalSince1970: 500))
        ]

        XCTAssertEqual(CardRemovalSummary.linkedStatementCycleCount(for: card, in: cycles), 2)
    }

    func testCardRemovalSummaryMessageMentionsHistoryWhenTransactionsExist() {
        let card = CreditCard(bankName: "HSBC", displayName: "HSBC Red", last4: "1234", statementDay: 15, dueRuleKind: .daysAfterStatement, dueDayOrOffset: 25)
        let transactions = [
            TransactionRecord(date: Date(timeIntervalSince1970: 0), merchant: "Cafe", categoryName: "dining", cardID: card.id, hkdAmount: Decimal(88))
        ]

        XCTAssertEqual(
            CardRemovalSummary.confirmationMessage(for: card, in: transactions),
            "This card has 1 linked transaction. Removing the card keeps the transaction in history, but it will no longer appear under this card."
        )
    }
}
