import Foundation

struct ExportDataUseCase: Sendable {
    private let userRepository: any UserRepository

    init(userRepository: any UserRepository) {
        self.userRepository = userRepository
    }

    func execute() async throws {
        try await userRepository.exportData()
    }
}
