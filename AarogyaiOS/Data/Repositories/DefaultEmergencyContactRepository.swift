import Foundation

struct DefaultEmergencyContactRepository: EmergencyContactRepository {
    private let apiClient: APIClient

    init(apiClient: APIClient) {
        self.apiClient = apiClient
    }

    func getContacts() async throws -> [EmergencyContact] {
        let response: [EmergencyContactResponse] = try await apiClient.request(.emergencyContacts)
        return response.map { EmergencyContactMapper.toDomain($0) }
    }

    func createContact(request: EmergencyContactInput) async throws -> EmergencyContact {
        let dto = EmergencyContactRequestDTO(
            name: request.name,
            phone: request.phone,
            relationship: request.relationship.rawValue,
            isPrimary: request.isPrimary
        )
        let response: EmergencyContactResponse = try await apiClient.request(
            .createEmergencyContact,
            body: dto
        )
        return EmergencyContactMapper.toDomain(response)
    }

    func updateContact(id: String, request: EmergencyContactInput) async throws -> EmergencyContact {
        let dto = EmergencyContactRequestDTO(
            name: request.name,
            phone: request.phone,
            relationship: request.relationship.rawValue,
            isPrimary: request.isPrimary
        )
        let response: EmergencyContactResponse = try await apiClient.request(
            .updateEmergencyContact(id: id),
            body: dto
        )
        return EmergencyContactMapper.toDomain(response)
    }

    func deleteContact(id: String) async throws {
        try await apiClient.requestNoContent(.deleteEmergencyContact(id: id))
    }

    func requestEmergencyAccess(contactPhone: String) async throws {
        let dto = EmergencyAccessRequestDTO(contactPhone: contactPhone)
        try await apiClient.requestNoContent(.requestEmergencyAccess, body: dto)
    }
}
