import CommonCrypto
import CryptoKit
import Foundation
import Security

struct EncryptedBackup: Codable, Equatable {
    let version: Int
    let kdfIterations: Int
    let salt: Data
    let nonce: Data
    let ciphertext: Data
    let tag: Data
}

enum BackupEnvelopeError: Error, Equatable {
    case invalidPassword
    case unsupportedVersion(Int)
    case randomGenerationFailed(OSStatus)
    case keyDerivationFailed(Int32)
}

enum BackupEnvelope {
    static let version = 1
    static let defaultKDFIterations = 210_000

    static func encrypt(payload: Data, password: String) throws -> EncryptedBackup {
        try validatePassword(password)
        let salt = try randomData(count: 16)
        let key = try deriveKey(password: password, salt: salt, iterations: defaultKDFIterations)
        let sealed = try AES.GCM.seal(payload, using: key)
        return EncryptedBackup(
            version: version,
            kdfIterations: defaultKDFIterations,
            salt: salt,
            nonce: sealed.nonce.withUnsafeBytes { Data($0) },
            ciphertext: sealed.ciphertext,
            tag: sealed.tag
        )
    }

    static func decrypt(envelope: EncryptedBackup, password: String) throws -> Data {
        try validatePassword(password)
        guard envelope.version == version else {
            throw BackupEnvelopeError.unsupportedVersion(envelope.version)
        }

        let key = try deriveKey(password: password, salt: envelope.salt, iterations: envelope.kdfIterations)
        let nonce = try AES.GCM.Nonce(data: envelope.nonce)
        let box = try AES.GCM.SealedBox(nonce: nonce, ciphertext: envelope.ciphertext, tag: envelope.tag)
        return try AES.GCM.open(box, using: key)
    }

    private static func validatePassword(_ password: String) throws {
        guard !password.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            throw BackupEnvelopeError.invalidPassword
        }
    }

    private static func deriveKey(password: String, salt: Data, iterations: Int) throws -> SymmetricKey {
        guard iterations > 0, iterations <= Int(UInt32.max) else {
            throw BackupEnvelopeError.keyDerivationFailed(Int32(kCCParamError))
        }

        let keyLength = 32
        var keyBytes = [UInt8](repeating: 0, count: keyLength)
        let passwordBytes = Array(password.utf8)
        let saltBytes = Array(salt)

        let status = password.withCString { passwordPointer in
            saltBytes.withUnsafeBufferPointer { saltBuffer in
                keyBytes.withUnsafeMutableBufferPointer { keyBuffer in
                    CCKeyDerivationPBKDF(
                        CCPBKDFAlgorithm(kCCPBKDF2),
                        passwordPointer,
                        passwordBytes.count,
                        saltBuffer.baseAddress,
                        saltBytes.count,
                        CCPseudoRandomAlgorithm(kCCPRFHmacAlgSHA256),
                        UInt32(iterations),
                        keyBuffer.baseAddress,
                        keyLength
                    )
                }
            }
        }

        guard status == kCCSuccess else {
            throw BackupEnvelopeError.keyDerivationFailed(status)
        }

        return SymmetricKey(data: keyBytes)
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
