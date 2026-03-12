import Foundation
@testable import AarogyaiOS

/// An in-memory device token store for unit testing, avoiding real Keychain access.
final class InMemoryDeviceTokenStore: DeviceTokenStoring, @unchecked Sendable {
    private var storedToken: String?

    var saveCallCount = 0
    var readCallCount = 0
    var deleteCallCount = 0
    var shouldThrowOnSave = false
    var shouldThrowOnDelete = false

    init(preloadedToken: String? = nil) {
        self.storedToken = preloadedToken
    }

    func saveToken(_ token: String) throws {
        saveCallCount += 1
        if shouldThrowOnSave {
            throw KeychainError.unexpectedStatus(-1)
        }
        storedToken = token
    }

    func readToken() -> String? {
        readCallCount += 1
        return storedToken
    }

    func deleteToken() throws {
        deleteCallCount += 1
        if shouldThrowOnDelete {
            throw KeychainError.unexpectedStatus(-1)
        }
        storedToken = nil
    }
}
