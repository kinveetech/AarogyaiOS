import Foundation

struct RegisterUserUseCase: Sendable {
    private let userRepository: any UserRepository

    init(userRepository: any UserRepository) {
        self.userRepository = userRepository
    }

    func execute(request: RegistrationRequest) async throws -> User {
        try await userRepository.register(request: request)
    }
}
