import Foundation

// MARK: - Social Auth DTOs

struct SocialAuthorizeRequest: Encodable, Sendable {
    let provider: String
    let codeChallenge: String
    let codeChallengeMethod: String
    let state: String
    let redirectUri: String
}

struct SocialAuthorizeResponse: Decodable, Sendable {
    let authorizeUrl: String
    let state: String
}

struct SocialTokenRequest: Encodable, Sendable {
    let provider: String
    let code: String
    let codeVerifier: String
    let redirectUri: String

    enum CodingKeys: String, CodingKey {
        case provider
        case code = "authorizationCode"
        case codeVerifier
        case redirectUri
    }
}

struct TokenResponse: Decodable, Sendable {
    let accessToken: String
    let refreshToken: String
    let idToken: String
    let expiresInSeconds: Int
    let tokenType: String
    let isLinkedAccount: Bool?
}
