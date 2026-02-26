import Foundation

// MARK: - Social Auth DTOs
// Backend uses camelCase JSON keys; explicit CodingKeys override the
// global snake_case encoder/decoder strategy used by APIClient.

struct SocialAuthorizeRequest: Encodable, Sendable {
    let provider: String
    let codeChallenge: String
    let codeChallengeMethod: String
    let state: String
    let redirectUri: String

    enum CodingKeys: String, CodingKey {
        case provider
        case codeChallenge
        case codeChallengeMethod
        case state
        case redirectUri
    }
}

struct SocialAuthorizeResponse: Decodable, Sendable {
    let authorizeUrl: String
    let state: String

    enum CodingKeys: String, CodingKey {
        case authorizeUrl
        case state
    }
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
    let expiresIn: Int
    let tokenType: String

    enum CodingKeys: String, CodingKey {
        case accessToken
        case refreshToken
        case idToken
        case expiresIn
        case tokenType
    }
}
