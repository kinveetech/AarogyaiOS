import Foundation

struct RevokeAccessGrantUseCase: Sendable {
    private let accessGrantRepository: any AccessGrantRepository

    init(accessGrantRepository: any AccessGrantRepository) {
        self.accessGrantRepository = accessGrantRepository
    }

    func execute(grantId: String) async throws {
        try await accessGrantRepository.revokeGrant(id: grantId)
    }
}
