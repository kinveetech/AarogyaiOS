import Foundation

struct SocialAuthorizeRequest: Encodable, Sendable {
    let provider: String
    let codeChallenge: String
    let codeChallengeMethod: String
    let state: String
    let redirectUri: String
}

struct SocialAuthorizeResponse: Decodable, Sendable {
    let authorizeUrl: String
}

struct SocialTokenRequest: Encodable, Sendable {
    let code: String
    let codeVerifier: String
    let state: String
    let redirectUri: String
}

struct TokenResponse: Decodable, Sendable {
    let accessToken: String
    let refreshToken: String
    let idToken: String
    let expiresIn: Int
    let tokenType: String
}
