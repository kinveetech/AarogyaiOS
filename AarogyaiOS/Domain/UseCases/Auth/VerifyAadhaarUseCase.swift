import Foundation

struct VerifyAadhaarUseCase: Sendable {
    private let userRepository: any UserRepository

    init(userRepository: any UserRepository) {
        self.userRepository = userRepository
    }

    func execute(token: String) async throws -> User {
        try await userRepository.verifyAadhaar(token: token)
    }
}
