import Foundation

struct RefreshTokenRequest: Encodable, Sendable {
    let refreshToken: String
}
