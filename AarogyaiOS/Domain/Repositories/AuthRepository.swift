import Foundation

struct SocialAuthSession: Sendable {
    let authorizeURL: URL
    let codeVerifier: String
    let state: String
}

protocol AuthRepository: Sendable {
    func socialAuthorize(provider: String) async throws -> SocialAuthSession
    func socialToken(code: String, codeVerifier: String) async throws -> AuthTokens
    func requestOTP(phone: String) async throws
    func verifyOTP(phone: String, otp: String) async throws -> AuthTokens
    func refreshToken(refreshToken: String) async throws -> AuthTokens
    func revokeToken(refreshToken: String) async throws
    func getCurrentUser() async throws -> User
}

struct AuthTokens: Sendable {
    let accessToken: String
    let refreshToken: String
    let idToken: String
    let expiresIn: Int
}
