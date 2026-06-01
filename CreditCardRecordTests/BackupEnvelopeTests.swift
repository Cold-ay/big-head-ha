import XCTest
@testable import CreditCardRecord

final class BackupEnvelopeTests: XCTestCase {
    func testEncryptDecryptRoundTrip() throws {
        let payload = Data("hello backup".utf8)
        let envelope = try BackupEnvelope.encrypt(payload: payload, password: "correct horse battery staple")
        let decrypted = try BackupEnvelope.decrypt(envelope: envelope, password: "correct horse battery staple")
        XCTAssertEqual(decrypted, payload)
        XCTAssertEqual(envelope.kdfIterations, BackupEnvelope.defaultKDFIterations)
    }

    func testWrongPasswordFails() throws {
        let envelope = try BackupEnvelope.encrypt(payload: Data("secret".utf8), password: "right")
        XCTAssertThrowsError(try BackupEnvelope.decrypt(envelope: envelope, password: "wrong"))
    }

    func testBlankPasswordRejectedOnEncrypt() {
        XCTAssertThrowsError(try BackupEnvelope.encrypt(payload: Data("secret".utf8), password: "  \n\t")) { error in
            XCTAssertEqual(error as? BackupEnvelopeError, .invalidPassword)
        }
    }

    func testBlankPasswordRejectedOnDecrypt() throws {
        let envelope = try BackupEnvelope.encrypt(payload: Data("secret".utf8), password: "right")

        XCTAssertThrowsError(try BackupEnvelope.decrypt(envelope: envelope, password: "  \n\t")) { error in
            XCTAssertEqual(error as? BackupEnvelopeError, .invalidPassword)
        }
    }

    func testUnsupportedVersionRejected() throws {
        let envelope = try BackupEnvelope.encrypt(payload: Data("secret".utf8), password: "right")
        let unsupportedEnvelope = EncryptedBackup(
            version: 2,
            kdfIterations: envelope.kdfIterations,
            salt: envelope.salt,
            nonce: envelope.nonce,
            ciphertext: envelope.ciphertext,
            tag: envelope.tag
        )

        XCTAssertThrowsError(try BackupEnvelope.decrypt(envelope: unsupportedEnvelope, password: "right")) { error in
            XCTAssertEqual(error as? BackupEnvelopeError, .unsupportedVersion(2))
        }
    }

    func testEncryptingSamePayloadTwiceProducesDifferentEnvelopeMaterial() throws {
        let payload = Data("secret".utf8)
        let password = "correct horse battery staple"

        let first = try BackupEnvelope.encrypt(payload: payload, password: password)
        let second = try BackupEnvelope.encrypt(payload: payload, password: password)

        XCTAssertTrue(first.salt != second.salt || first.nonce != second.nonce || first.ciphertext != second.ciphertext)
    }
}
