import Foundation

struct FetchEmergencyAccessAuditUseCase: Sendable {
    private let emergencyAccessRepository: any EmergencyAccessRepository

    init(emergencyAccessRepository: any EmergencyAccessRepository) {
        self.emergencyAccessRepository = emergencyAccessRepository
    }

    func execute(page: Int = 1, pageSize: Int = 20) async throws -> PaginatedResult<EmergencyAccessAuditEntry> {
        try await emergencyAccessRepository.getAuditTrail(page: page, pageSize: pageSize)
    }
}
