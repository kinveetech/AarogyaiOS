import Foundation

struct DefaultConsentRepository: ConsentRepository {
    private let apiClient: APIClient

    init(apiClient: APIClient) {
        self.apiClient = apiClient
    }

    func upsertConsent(purpose: ConsentPurpose, isGranted: Bool) async throws -> ConsentRecord {
        let dto = UpsertConsentRequestDTO(isGranted: isGranted)
        let response: ConsentRecordResponse = try await apiClient.request(
            .upsertConsent(purpose: purpose.rawValue),
            body: dto
        )
        return ConsentMapper.toDomain(response)
    }
}
