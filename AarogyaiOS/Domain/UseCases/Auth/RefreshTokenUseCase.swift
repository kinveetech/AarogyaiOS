import Foundation

struct RefreshTokenUseCase: Sendable {
    private let authRepository: any AuthRepository
    private let tokenStore: any TokenStoring

    init(authRepository: any AuthRepository, tokenStore: any TokenStoring) {
        self.authRepository = authRepository
        self.tokenStore = tokenStore
    }

    func execute() async throws -> AuthTokens {
        guard let refreshToken = try? await tokenStore.refreshToken() else {
            throw AuthError.noRefreshToken
        }
        let tokens = try await authRepository.refreshToken(refreshToken: refreshToken)
        try await tokenStore.store(tokens)
        return tokens
    }
}

enum AuthError: Error, Sendable {
    case noRefreshToken
    case sessionExpired
}
