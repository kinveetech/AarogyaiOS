import Foundation

struct FetchEmergencyContactsUseCase: Sendable {
    private let emergencyContactRepository: any EmergencyContactRepository

    init(emergencyContactRepository: any EmergencyContactRepository) {
        self.emergencyContactRepository = emergencyContactRepository
    }

    func execute() async throws -> [EmergencyContact] {
        try await emergencyContactRepository.getContacts()
    }
}
