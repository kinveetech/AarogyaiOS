import Foundation

protocol TokenStoring: Sendable {
    func store(_ tokens: AuthTokens) async throws
    func accessToken() async throws -> String
    func refreshToken() async throws -> String
    func idToken() async throws -> String
    func clearAll() async throws
}
