import Foundation

struct TokenStore: TokenStoring {
    private let keychain: KeychainService

    init(keychain: KeychainService = KeychainService()) {
        self.keychain = keychain
    }

    func store(_ tokens: AuthTokens) async throws {
        try keychain.save(tokens.accessToken, for: Constants.Keychain.accessTokenKey)
        try keychain.save(tokens.refreshToken, for: Constants.Keychain.refreshTokenKey)
        try keychain.save(tokens.idToken, for: Constants.Keychain.idTokenKey)
    }

    func accessToken() async throws -> String {
        try keychain.readString(key: Constants.Keychain.accessTokenKey)
    }

    func refreshToken() async throws -> String {
        try keychain.readString(key: Constants.Keychain.refreshTokenKey)
    }

    func idToken() async throws -> String {
        try keychain.readString(key: Constants.Keychain.idTokenKey)
    }

    func clearAll() async throws {
        try keychain.deleteAll()
    }
}
