import Foundation
import OSLog

struct DefaultAuthRepository: AuthRepository {
    private let apiClient: APIClient
    private let tokenStore: any TokenStoring

    init(apiClient: APIClient, tokenStore: any TokenStoring) {
        self.apiClient = apiClient
        self.tokenStore = tokenStore
    }

    func socialAuthorize(provider: String) async throws -> SocialAuthSession {
        let codeVerifier = PKCEGenerator.generateCodeVerifier()
        let codeChallenge = PKCEGenerator.generateCodeChallenge(
            from: codeVerifier
        )
        let state = PKCEGenerator.generateState()

        let request = SocialAuthorizeRequest(
            provider: provider,
            codeChallenge: codeChallenge,
            codeChallengeMethod: "S256",
            state: state,
            redirectUri: "aarogya://auth/callback"
        )

        let response: SocialAuthorizeResponse = try await apiClient.request(
            .socialAuthorize,
            body: request
        )

        guard let url = URL(string: response.authorizeUrl) else {
            throw APIError.decodingError(underlying: URLError(.badURL))
        }

        return SocialAuthSession(
            authorizeURL: url,
            codeVerifier: codeVerifier,
            state: state
        )
    }

    func socialToken(provider: String, code: String, codeVerifier: String) async throws -> AuthTokens {
        let request = SocialTokenRequest(
            provider: provider,
            code: code,
            codeVerifier: codeVerifier,
            redirectUri: "aarogya://auth/callback"
        )
        let response: TokenResponse = try await apiClient.request(.socialToken, body: request)
        return UserMapper.toTokens(response)
    }

    func requestOTP(phone: String) async throws {
        try await apiClient.requestNoContent(.otpRequest, body: OtpRequestDTO(phone: phone))
    }

    func verifyOTP(phone: String, otp: String) async throws -> AuthTokens {
        let request = OtpVerifyRequest(phone: phone, otp: otp)
        let response: TokenResponse = try await apiClient.request(.otpVerify, body: request)
        return UserMapper.toTokens(response)
    }

    func refreshToken(refreshToken: String) async throws -> AuthTokens {
        let request = RefreshTokenRequest(refreshToken: refreshToken)
        let response: TokenResponse = try await apiClient.request(.tokenRefresh, body: request)
        return UserMapper.toTokens(response)
    }

    func revokeToken(refreshToken: String) async throws {
        try await apiClient.requestNoContent(
            .tokenRevoke,
            body: RefreshTokenRequest(refreshToken: refreshToken)
        )
    }

    func getCurrentUser() async throws -> User {
        let response: UserProfileResponse = try await apiClient.request(.authMe)
        return UserMapper.toDomain(response)
    }
}
