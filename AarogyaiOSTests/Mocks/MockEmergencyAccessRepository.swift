import Foundation
@testable import AarogyaiOS

final class MockEmergencyAccessRepository: EmergencyAccessRepository, @unchecked Sendable {
    var getAuditTrailResult: Result<PaginatedResult<EmergencyAccessAuditEntry>, Error> = .success(
        PaginatedResult(items: [.stub], page: 1, pageSize: 20, totalCount: 1)
    )

    var getAuditTrailCallCount = 0
    var lastRequestedPage: Int?
    var lastRequestedPageSize: Int?

    func getAuditTrail(page: Int, pageSize: Int) async throws -> PaginatedResult<EmergencyAccessAuditEntry> {
        getAuditTrailCallCount += 1
        lastRequestedPage = page
        lastRequestedPageSize = pageSize
        return try getAuditTrailResult.get()
    }
}
