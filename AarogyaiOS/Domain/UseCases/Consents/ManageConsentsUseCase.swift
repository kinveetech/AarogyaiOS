import Foundation

struct ManageConsentsUseCase: Sendable {
    private let consentRepository: any ConsentRepository

    init(consentRepository: any ConsentRepository) {
        self.consentRepository = consentRepository
    }

    func upsert(purpose: ConsentPurpose, isGranted: Bool) async throws -> ConsentRecord {
        try await consentRepository.upsertConsent(purpose: purpose, isGranted: isGranted)
    }
}
