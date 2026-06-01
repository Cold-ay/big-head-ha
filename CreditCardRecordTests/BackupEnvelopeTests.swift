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
