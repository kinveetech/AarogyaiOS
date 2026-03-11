import CryptoKit
import Foundation
import OSLog

enum ChecksumValidationError: Error, Sendable {
    case checksumMismatch(expected: String, actual: String)
    case fileReadError(underlying: any Error)
}

enum ChecksumValidator: Sendable {
    /// Computes the SHA-256 hash of the given data and returns it as a lowercase hex string.
    nonisolated static func sha256Hash(of data: Data) -> String {
        let digest = SHA256.hash(data: data)
        return digest.map { String(format: "%02x", $0) }.joined()
    }

    /// Validates that the SHA-256 hash of the given data matches the expected checksum.
    ///
    /// - Parameters:
    ///   - data: The file data to validate.
    ///   - expectedChecksum: The expected SHA-256 hex string (case-insensitive).
    /// - Throws: `ChecksumValidationError.checksumMismatch` if hashes do not match.
    nonisolated static func validate(data: Data, expectedChecksum: String) throws {
        let actual = sha256Hash(of: data)
        guard actual.lowercased() == expectedChecksum.lowercased() else {
            Logger.data.error("Checksum mismatch for downloaded file")
            throw ChecksumValidationError.checksumMismatch(
                expected: expectedChecksum.lowercased(),
                actual: actual
            )
        }
    }
}
