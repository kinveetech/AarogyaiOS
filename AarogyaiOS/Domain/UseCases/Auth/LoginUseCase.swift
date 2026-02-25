import Foundation

struct LoginUseCase: Sendable {
    private let authRepository: any AuthRepository
    private let tokenStore: any TokenStoring

    init(authRepository: any AuthRepository, tokenStore: any TokenStoring) {
        self.authRepository = authRepository
        self.tokenStore = tokenStore
    }

    func executeSocial(provider: String, code: String, codeVerifier: String) async throws -> User {
        let tokens = try await authRepository.socialToken(code: code, codeVerifier: codeVerifier)
        try await tokenStore.store(tokens)
        return try await authRepository.getCurrentUser()
    }

    func executeOTP(phone: String, otp: String) async throws -> User {
        let tokens = try await authRepository.verifyOTP(phone: phone, otp: otp)
        try await tokenStore.store(tokens)
        return try await authRepository.getCurrentUser()
    }

    func requestOTP(phone: String) async throws {
        try await authRepository.requestOTP(phone: phone)
    }

    func getAuthorizeURL(provider: String) async throws -> URL {
        try await authRepository.socialAuthorize(provider: provider)
    }
}
