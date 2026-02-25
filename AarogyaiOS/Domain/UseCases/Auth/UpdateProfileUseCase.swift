import Foundation

struct UpdateProfileUseCase: Sendable {
    private let userRepository: any UserRepository

    init(userRepository: any UserRepository) {
        self.userRepository = userRepository
    }

    func execute(user: User) async throws -> User {
        try await userRepository.updateProfile(user)
    }
}
