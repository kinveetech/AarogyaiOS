import Foundation

struct DefaultEmergencyAccessRepository: EmergencyAccessRepository {
    private let apiClient: APIClient

    init(apiClient: APIClient) {
        self.apiClient = apiClient
    }

    func getAuditTrail(page: Int, pageSize: Int) async throws -> PaginatedResult<EmergencyAccessAuditEntry> {
        let response: EmergencyAccessAuditTrailDTO = try await apiClient.request(
            .emergencyAccessAudit(page: page, pageSize: pageSize)
        )
        let entries = response.items.map { EmergencyAccessAuditMapper.toDomain($0) }
        return PaginatedResult(
            items: entries,
            page: response.page,
            pageSize: response.pageSize,
            totalCount: response.totalCount
        )
    }
}
