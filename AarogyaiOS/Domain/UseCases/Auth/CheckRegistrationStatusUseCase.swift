import Foundation

struct CheckRegistrationStatusUseCase: Sendable {
    private let userRepository: any UserRepository

    init(userRepository: any UserRepository) {
        self.userRepository = userRepository
    }

    func execute() async throws -> RegistrationStatus {
        try await userRepository.getRegistrationStatus()
    }
}
