import Foundation
@testable import AarogyaiOS

final class MockConsentRepository: ConsentRepository, @unchecked Sendable {
    var upsertConsentResult: Result<ConsentRecord, Error> = .success(
        ConsentRecord(purpose: .profileManagement, isGranted: true, source: "app", occurredAt: .now)
    )

    var upsertConsentCallCount = 0
    var lastUpsertedPurpose: ConsentPurpose?
    var lastUpsertedIsGranted: Bool?

    func upsertConsent(purpose: ConsentPurpose, isGranted: Bool) async throws -> ConsentRecord {
        upsertConsentCallCount += 1
        lastUpsertedPurpose = purpose
        lastUpsertedIsGranted = isGranted
        return try upsertConsentResult.get()
    }
}
