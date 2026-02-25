import Testing
@testable import AarogyaiOS

@Suite("MockTokenStore")
struct TokenStoreTests {
    @Test func storeAndRetrieveTokens() async throws {
        let store = MockTokenStore()
        let tokens = AuthTokens(
            accessToken: "my-access",
            refreshToken: "my-refresh",
            idToken: "my-id",
            expiresIn: 1800
        )
        try await store.store(tokens)
        #expect(store.storedTokens?.accessToken == "my-access")
        #expect(store.storeCallCount == 1)
    }

    @Test func clearAllRemovesTokens() async throws {
        let store = MockTokenStore()
        let tokens = AuthTokens.stub
        try await store.store(tokens)
        try await store.clearAll()
        #expect(store.storedTokens == nil)
        #expect(store.clearAllCallCount == 1)
    }

    @Test func accessTokenReturnsConfiguredValue() async throws {
        let store = MockTokenStore()
        store.accessTokenResult = .success("custom-token")
        let token = try await store.accessToken()
        #expect(token == "custom-token")
    }

    @Test func accessTokenThrowsOnError() async {
        let store = MockTokenStore()
        store.accessTokenResult = .failure(APIError.tokenRefreshFailed)
        await #expect(throws: APIError.self) {
            _ = try await store.accessToken()
        }
    }
}
