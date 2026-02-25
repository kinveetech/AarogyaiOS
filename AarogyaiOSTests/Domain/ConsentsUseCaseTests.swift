import Testing
@testable import AarogyaiOS

@Suite("ManageConsentsUseCase")
struct ManageConsentsUseCaseTests {
    let repo = MockConsentRepository()

    var sut: ManageConsentsUseCase {
        ManageConsentsUseCase(consentRepository: repo)
    }

    @Test func upsertCallsRepository() async throws {
        let record = try await sut.upsert(purpose: .medicalDataSharing, isGranted: true)
        #expect(record.isGranted)
        #expect(repo.upsertConsentCallCount == 1)
        #expect(repo.lastUpsertedPurpose == .medicalDataSharing)
        #expect(repo.lastUpsertedIsGranted == true)
    }
}

@Suite("ManageNotificationsUseCase")
struct ManageNotificationsUseCaseTests {
    let repo = MockNotificationRepository()

    var sut: ManageNotificationsUseCase {
        ManageNotificationsUseCase(notificationRepository: repo)
    }

    @Test func getPreferencesCallsRepository() async throws {
        let prefs = try await sut.getPreferences()
        #expect(prefs.reportUploaded.push)
        #expect(repo.getPreferencesCallCount == 1)
    }

    @Test func updatePreferencesCallsRepository() async throws {
        let prefs = NotificationPreferences.stub
        let updated = try await sut.updatePreferences(prefs)
        #expect(updated.reportUploaded.push)
        #expect(repo.updatePreferencesCallCount == 1)
    }
}
