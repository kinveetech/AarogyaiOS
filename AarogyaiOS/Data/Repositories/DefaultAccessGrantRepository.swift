import Foundation

struct DefaultAccessGrantRepository: AccessGrantRepository {
    private let apiClient: APIClient

    init(apiClient: APIClient) {
        self.apiClient = apiClient
    }

    func createGrant(request: CreateAccessGrantInput) async throws -> AccessGrant {
        let dto = CreateAccessGrantRequestDTO(
            grantedToUserId: request.grantedToUserId,
            allReports: request.scope.allReports,
            reportIds: request.scope.allReports ? nil : request.scope.reportIds,
            grantReason: request.grantReason,
            expiresAt: request.expiresAt?.iso8601String
        )
        let response: AccessGrantResponse = try await apiClient.request(.createAccessGrant, body: dto)
        return AccessGrantMapper.toDomain(response)
    }

    func getGrants() async throws -> [AccessGrant] {
        let response: [AccessGrantResponse] = try await apiClient.request(.accessGrants)
        return response.map { AccessGrantMapper.toDomain($0) }
    }

    func getReceivedGrants() async throws -> [AccessGrant] {
        let response: [AccessGrantResponse] = try await apiClient.request(.accessGrantsReceived)
        return response.map { AccessGrantMapper.toDomain($0) }
    }

    func revokeGrant(id: String) async throws {
        try await apiClient.requestNoContent(.revokeAccessGrant(id: id))
    }
}
