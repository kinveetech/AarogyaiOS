import Foundation
import Testing
@testable import AarogyaiOS

@Suite("ChecksumValidator")
struct ChecksumValidatorTests {
    @Test("SHA-256 hash computation produces correct hex string")
    func sha256HashComputation() async {
        // "hello world" SHA-256 = b94d27b9934d3e08a52e52d7da7dabfac484efe37a5380ee9088f7ace2efcde9
        let data = Data("hello world".utf8)
        let hash = ChecksumValidator.sha256Hash(of: data)
        #expect(hash == "b94d27b9934d3e08a52e52d7da7dabfac484efe37a5380ee9088f7ace2efcde9")
    }

    @Test("SHA-256 hash of empty data")
    func sha256HashEmptyData() async {
        // SHA-256 of empty input = e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855
        let data = Data()
        let hash = ChecksumValidator.sha256Hash(of: data)
        #expect(hash == "e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855")
    }

    @Test("Validation succeeds when checksum matches")
    func validationSucceedsOnMatch() async throws {
        let data = Data("hello world".utf8)
        let expectedChecksum = "b94d27b9934d3e08a52e52d7da7dabfac484efe37a5380ee9088f7ace2efcde9"
        try ChecksumValidator.validate(data: data, expectedChecksum: expectedChecksum)
    }

    @Test("Validation succeeds with case-insensitive checksum")
    func validationSucceedsCaseInsensitive() async throws {
        let data = Data("hello world".utf8)
        let expectedChecksum = "B94D27B9934D3E08A52E52D7DA7DABFAC484EFE37A5380EE9088F7ACE2EFCDE9"
        try ChecksumValidator.validate(data: data, expectedChecksum: expectedChecksum)
    }

    @Test("Validation throws on checksum mismatch")
    func validationThrowsOnMismatch() async {
        let data = Data("hello world".utf8)
        let wrongChecksum = "0000000000000000000000000000000000000000000000000000000000000000"
        #expect(throws: ChecksumValidationError.self) {
            try ChecksumValidator.validate(data: data, expectedChecksum: wrongChecksum)
        }
    }

    @Test("Mismatch error contains expected and actual checksums")
    func mismatchErrorContainsDetails() async {
        let data = Data("test".utf8)
        let wrongChecksum = "0000000000000000000000000000000000000000000000000000000000000000"

        do {
            try ChecksumValidator.validate(data: data, expectedChecksum: wrongChecksum)
            Issue.record("Expected ChecksumValidationError to be thrown")
        } catch let error as ChecksumValidationError {
            if case .checksumMismatch(let expected, let actual) = error {
                #expect(expected == wrongChecksum)
                #expect(actual == ChecksumValidator.sha256Hash(of: data))
            } else {
                Issue.record("Unexpected error case: \(error)")
            }
        } catch {
            Issue.record("Unexpected error type: \(error)")
        }
    }

    @Test("Different data produces different hashes")
    func differentDataDifferentHashes() async {
        let data1 = Data("hello".utf8)
        let data2 = Data("world".utf8)
        let hash1 = ChecksumValidator.sha256Hash(of: data1)
        let hash2 = ChecksumValidator.sha256Hash(of: data2)
        #expect(hash1 != hash2)
    }

    @Test("Hash is deterministic for same input")
    func hashIsDeterministic() async {
        let data = Data("deterministic test".utf8)
        let hash1 = ChecksumValidator.sha256Hash(of: data)
        let hash2 = ChecksumValidator.sha256Hash(of: data)
        #expect(hash1 == hash2)
    }
}
