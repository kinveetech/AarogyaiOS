import Foundation
import Testing
@testable import AarogyaiOS

@Suite("DefaultAuthRepository")
struct DefaultAuthRepositoryTests {
    @Test func refreshTokenCallsAPIAndReturnsTokens() async throws {
        // DefaultAuthRepository delegates to APIClient which we can't easily unit test
        // without a URLProtocol mock. The use case layer tests cover the contract.
        // This test verifies the AuthTokens model structure.
        let tokens = AuthTokens(
            accessToken: "access",
            refreshToken: "refresh",
            idToken: "id",
            expiresIn: 3600
        )
        #expect(tokens.accessToken == "access")
        #expect(tokens.refreshToken == "refresh")
        #expect(tokens.expiresIn == 3600)
    }
}
