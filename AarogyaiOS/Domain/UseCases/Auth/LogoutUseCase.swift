import Foundation

struct LogoutUseCase: Sendable {
    private let authRepository: any AuthRepository
    private let tokenStore: any TokenStoring

    init(authRepository: any AuthRepository, tokenStore: any TokenStoring) {
        self.authRepository = authRepository
        self.tokenStore = tokenStore
    }

    func execute() async throws {
        if let refreshToken = try? await tokenStore.refreshToken() {
            try? await authRepository.revokeToken(refreshToken: refreshToken)
        }
        try await tokenStore.clearAll()
    }
}
