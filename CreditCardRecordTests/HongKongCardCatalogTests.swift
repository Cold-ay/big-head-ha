import XCTest
@testable import CreditCardRecord

final class HongKongCardCatalogTests: XCTestCase {
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
}
