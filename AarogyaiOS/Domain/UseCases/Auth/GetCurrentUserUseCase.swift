import Foundation

struct GetCurrentUserUseCase: Sendable {
    private let userRepository: any UserRepository

    init(userRepository: any UserRepository) {
        self.userRepository = userRepository
    }

    func execute() async throws -> User {
        try await userRepository.getProfile()
    }
}
