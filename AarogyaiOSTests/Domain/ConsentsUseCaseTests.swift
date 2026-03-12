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

    @Test func registerDeviceCallsRepository() async throws {
        let deviceToken = try await sut.registerDevice(token: "test-push-token")
        #expect(deviceToken.id == "dt-1")
        #expect(repo.registerDeviceCallCount == 1)
        #expect(repo.lastRegisteredToken == "test-push-token")
    }

    @Test func unregisterDeviceCallsRepository() async throws {
        try await sut.unregisterDevice(token: "test-push-token")
        #expect(repo.unregisterDeviceCallCount == 1)
        #expect(repo.lastUnregisteredToken == "test-push-token")
    }

    @Test func registerDevicePropagatesError() async {
        repo.registerDeviceResult = .failure(APIError.serverError(status: 500))
        do {
            _ = try await sut.registerDevice(token: "token")
            Issue.record("Expected error to be thrown")
        } catch {
            #expect(error is APIError)
        }
    }

    @Test func unregisterDevicePropagatesError() async {
        repo.unregisterDeviceResult = .failure(APIError.serverError(status: 500))
        do {
            try await sut.unregisterDevice(token: "token")
            Issue.record("Expected error to be thrown")
        } catch {
            #expect(error is APIError)
        }
    }
}
