import Foundation

protocol ConsentRepository: Sendable {
    func upsertConsent(purpose: ConsentPurpose, isGranted: Bool) async throws -> ConsentRecord
}
