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
