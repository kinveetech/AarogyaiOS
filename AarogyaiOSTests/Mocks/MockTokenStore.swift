import Foundation
@testable import AarogyaiOS

final class MockTokenStore: TokenStoring, @unchecked Sendable {
    var storedTokens: AuthTokens?
    var storeResult: Result<Void, Error> = .success(())
    var accessTokenResult: Result<String, Error> = .success("mock-access-token")
    var refreshTokenResult: Result<String, Error> = .success("mock-refresh-token")
    var idTokenResult: Result<String, Error> = .success("mock-id-token")
    var clearAllResult: Result<Void, Error> = .success(())

    var storeCallCount = 0
    var clearAllCallCount = 0

    func store(_ tokens: AuthTokens) async throws {
        storeCallCount += 1
        storedTokens = tokens
        try storeResult.get()
    }

    func accessToken() async throws -> String {
        try accessTokenResult.get()
    }

    func refreshToken() async throws -> String {
        try refreshTokenResult.get()
    }

    func idToken() async throws -> String {
        try idTokenResult.get()
    }

    func clearAll() async throws {
        clearAllCallCount += 1
        storedTokens = nil
        try clearAllResult.get()
    }
}
