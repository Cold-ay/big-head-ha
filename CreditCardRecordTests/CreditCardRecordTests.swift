import XCTest
@testable import CreditCardRecord

final class CreditCardRecordTests: XCTestCase {
    func testAppNameConstant() {
        XCTAssertEqual(AppConstants.appName, "BigHeadHa")
    }

    func testInstalledBundleUsesBigHeadHaBrandAndAppIcon() {
        XCTAssertEqual(Bundle.main.object(forInfoDictionaryKey: "CFBundleDisplayName") as? String, "BigHeadHa")
        let icons = Bundle.main.object(forInfoDictionaryKey: "CFBundleIcons") as? [String: Any]
        let primary = icons?["CFBundlePrimaryIcon"] as? [String: Any]
        XCTAssertEqual(primary?["CFBundleIconName"] as? String, "AppIcon")
        XCTAssertNotNil(Bundle.main.url(forResource: "Assets", withExtension: "car"))
    }
}
