import Foundation
@testable import AarogyaiOS

final class MockAuthRepository: AuthRepository, @unchecked Sendable {
    var socialAuthorizeResult: Result<SocialAuthSession, Error> = .success(
        SocialAuthSession(authorizeURL: URL(string: "https://auth.example.com")!, codeVerifier: "test-verifier", state: "test-state")
    )
    var socialTokenResult: Result<AuthTokens, Error> = .success(.stub)
    var requestOTPResult: Result<Void, Error> = .success(())
    var verifyOTPResult: Result<AuthTokens, Error> = .success(.stub)
    var refreshTokenResult: Result<AuthTokens, Error> = .success(.stub)
    var revokeTokenResult: Result<Void, Error> = .success(())
    var getCurrentUserResult: Result<User, Error> = .success(.stub)

    var socialAuthorizeCallCount = 0
    var socialTokenCallCount = 0
    var requestOTPCallCount = 0
    var verifyOTPCallCount = 0
    var refreshTokenCallCount = 0
    var revokeTokenCallCount = 0
    var getCurrentUserCallCount = 0

    var lastRequestedOTPPhone: String?
    var lastVerifiedPhone: String?
    var lastVerifiedOTP: String?

    func socialAuthorize(provider: String) async throws -> SocialAuthSession {
        socialAuthorizeCallCount += 1
        return try socialAuthorizeResult.get()
    }

    func socialToken(provider: String, code: String, codeVerifier: String) async throws -> AuthTokens {
        socialTokenCallCount += 1
        return try socialTokenResult.get()
    }

    func requestOTP(phone: String) async throws {
        requestOTPCallCount += 1
        lastRequestedOTPPhone = phone
        try requestOTPResult.get()
    }

    func verifyOTP(phone: String, otp: String) async throws -> AuthTokens {
        verifyOTPCallCount += 1
        lastVerifiedPhone = phone
        lastVerifiedOTP = otp
        return try verifyOTPResult.get()
    }

    func refreshToken(refreshToken: String) async throws -> AuthTokens {
        refreshTokenCallCount += 1
        return try refreshTokenResult.get()
    }

    func revokeToken(refreshToken: String) async throws {
        revokeTokenCallCount += 1
        try revokeTokenResult.get()
    }

    func getCurrentUser() async throws -> User {
        getCurrentUserCallCount += 1
        return try getCurrentUserResult.get()
    }
}
