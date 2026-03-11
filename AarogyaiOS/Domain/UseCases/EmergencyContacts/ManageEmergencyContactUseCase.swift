import Foundation

struct ManageEmergencyContactUseCase: Sendable {
    private let emergencyContactRepository: any EmergencyContactRepository

    init(emergencyContactRepository: any EmergencyContactRepository) {
        self.emergencyContactRepository = emergencyContactRepository
    }

    func create(request: EmergencyContactInput) async throws -> EmergencyContact {
        try await emergencyContactRepository.createContact(request: request)
    }

    func update(id: String, request: EmergencyContactInput) async throws -> EmergencyContact {
        try await emergencyContactRepository.updateContact(id: id, request: request)
    }

    func delete(id: String) async throws {
        try await emergencyContactRepository.deleteContact(id: id)
    }

    func requestEmergencyAccess(input: EmergencyAccessInput) async throws -> EmergencyAccessGrant {
        try await emergencyContactRepository.requestEmergencyAccess(input: input)
    }
}
