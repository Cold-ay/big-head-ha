import CryptoKit
import Foundation
import Security

struct EncryptedBackup: Codable, Equatable {
    let version: Int
    let salt: Data
    let nonce: Data
    let ciphertext: Data
    let tag: Data
}

enum BackupEnvelopeError: Error, Equatable {
    case randomGenerationFailed(OSStatus)
}

enum BackupEnvelope {
    static func encrypt(payload: Data, password: String) throws -> EncryptedBackup {
        let salt = try randomData(count: 16)
        let key = SymmetricKey(data: SHA256.hash(data: Data(password.utf8) + salt))
        let sealed = try AES.GCM.seal(payload, using: key)
        return EncryptedBackup(
            version: 1,
            salt: salt,
            nonce: sealed.nonce.withUnsafeBytes { Data($0) },
            ciphertext: sealed.ciphertext,
            tag: sealed.tag
        )
    }

    static func decrypt(envelope: EncryptedBackup, password: String) throws -> Data {
        let key = SymmetricKey(data: SHA256.hash(data: Data(password.utf8) + envelope.salt))
        let nonce = try AES.GCM.Nonce(data: envelope.nonce)
        let box = try AES.GCM.SealedBox(nonce: nonce, ciphertext: envelope.ciphertext, tag: envelope.tag)
        return try AES.GCM.open(box, using: key)
    }

    private static func randomData(count: Int) throws -> Data {
        var bytes = [UInt8](repeating: 0, count: count)
        let status = SecRandomCopyBytes(kSecRandomDefault, bytes.count, &bytes)
        guard status == errSecSuccess else {
            throw BackupEnvelopeError.randomGenerationFailed(status)
        }
        return Data(bytes)
    }
}
