import Foundation

protocol EmergencyAccessRepository: Sendable {
    func getAuditTrail(page: Int, pageSize: Int) async throws -> PaginatedResult<EmergencyAccessAuditEntry>
}
