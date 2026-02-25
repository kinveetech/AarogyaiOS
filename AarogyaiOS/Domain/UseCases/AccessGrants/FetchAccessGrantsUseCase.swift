import Foundation

struct FetchAccessGrantsUseCase: Sendable {
    private let accessGrantRepository: any AccessGrantRepository

    init(accessGrantRepository: any AccessGrantRepository) {
        self.accessGrantRepository = accessGrantRepository
    }

    func executeGiven() async throws -> [AccessGrant] {
        try await accessGrantRepository.getGrants()
    }

    func executeReceived() async throws -> [AccessGrant] {
        try await accessGrantRepository.getReceivedGrants()
    }
}
