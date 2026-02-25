import Foundation

struct CreateAccessGrantUseCase: Sendable {
    private let accessGrantRepository: any AccessGrantRepository

    init(accessGrantRepository: any AccessGrantRepository) {
        self.accessGrantRepository = accessGrantRepository
    }

    func execute(request: CreateAccessGrantInput) async throws -> AccessGrant {
        try await accessGrantRepository.createGrant(request: request)
    }
}
