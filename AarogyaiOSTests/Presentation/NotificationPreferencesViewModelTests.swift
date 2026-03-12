import Foundation
import Testing
@testable import AarogyaiOS

@Suite("NotificationPreferencesViewModel")
@MainActor
struct NotificationPreferencesViewModelTests {
    let notifRepo = MockNotificationRepository()

    func makeSUT() -> NotificationPreferencesViewModel {
        NotificationPreferencesViewModel(
            manageNotificationsUseCase: ManageNotificationsUseCase(notificationRepository: notifRepo)
        )
    }

    // MARK: - Initial State

    @Test func initialStateHasDefaults() {
        let sut = makeSUT()
        #expect(sut.reportUploaded == ChannelPreferences(push: true, email: true, sms: false))
        #expect(sut.accessGranted == ChannelPreferences(push: true, email: true, sms: false))
        #expect(sut.emergencyAccess == ChannelPreferences(push: true, email: true, sms: true))
        #expect(!sut.isLoading)
        #expect(!sut.isSaving)
        #expect(sut.error == nil)
        #expect(!sut.saveSuccess)
    }

    @Test func hasChangesReturnsFalseBeforeLoad() {
        let sut = makeSUT()
        #expect(!sut.hasChanges)
    }

    // MARK: - Load Preferences

    @Test func loadPreferencesPopulatesFromRepository() async {
        let customPrefs = NotificationPreferences(
            reportUploaded: ChannelPreferences(push: false, email: true, sms: true),
            accessGranted: ChannelPreferences(push: true, email: false, sms: true),
            emergencyAccess: ChannelPreferences(push: false, email: false, sms: false)
        )
        notifRepo.getPreferencesResult = .success(customPrefs)
        let sut = makeSUT()
        await sut.loadPreferences()

        #expect(sut.reportUploaded == customPrefs.reportUploaded)
        #expect(sut.accessGranted == customPrefs.accessGranted)
        #expect(sut.emergencyAccess == customPrefs.emergencyAccess)
        #expect(!sut.isLoading)
        #expect(sut.error == nil)
    }

    @Test func loadPreferencesCallsRepository() async {
        let sut = makeSUT()
        await sut.loadPreferences()
        #expect(notifRepo.getPreferencesCallCount == 1)
    }

    @Test func loadPreferencesSetsIsLoadingFalseAfterCompletion() async {
        let sut = makeSUT()
        await sut.loadPreferences()
        #expect(!sut.isLoading)
    }

    @Test func loadPreferencesClearsErrorOnNewAttempt() async {
        notifRepo.getPreferencesResult = .failure(APIError.serverError(status: 500))
        let sut = makeSUT()
        await sut.loadPreferences()
        #expect(sut.error != nil)

        notifRepo.getPreferencesResult = .success(.stub)
        await sut.loadPreferences()
        #expect(sut.error == nil)
    }

    @Test func loadPreferencesFailureSetsGenericError() async {
        struct CustomError: Error {}
        notifRepo.getPreferencesResult = .failure(CustomError())
        let sut = makeSUT()
        await sut.loadPreferences()
        #expect(sut.error == "Failed to load notification preferences")
        #expect(!sut.isLoading)
    }

    @Test func loadPreferencesHandlesServerError() async {
        notifRepo.getPreferencesResult = .failure(APIError.serverError(status: 500))
        let sut = makeSUT()
        await sut.loadPreferences()
        #expect(sut.error == "Server error. Please try again later.")
    }

    @Test func loadPreferencesHandlesNetworkError() async {
        notifRepo.getPreferencesResult = .failure(
            APIError.networkError(underlying: URLError(.notConnectedToInternet))
        )
        let sut = makeSUT()
        await sut.loadPreferences()
        #expect(sut.error == "Network error. Check your connection and try again.")
    }

    @Test func loadPreferencesHandlesUnauthorizedError() async {
        notifRepo.getPreferencesResult = .failure(APIError.unauthorized)
        let sut = makeSUT()
        await sut.loadPreferences()
        #expect(sut.error == "Session expired. Please sign in again.")
    }

    @Test func loadPreferencesHandlesTokenRefreshFailed() async {
        notifRepo.getPreferencesResult = .failure(APIError.tokenRefreshFailed)
        let sut = makeSUT()
        await sut.loadPreferences()
        #expect(sut.error == "Session expired. Please sign in again.")
    }

    @Test func loadPreferencesHandlesRateLimited() async {
        notifRepo.getPreferencesResult = .failure(APIError.rateLimited(retryAfter: 60))
        let sut = makeSUT()
        await sut.loadPreferences()
        #expect(sut.error == "Too many requests. Please try again later.")
    }

    @Test func loadPreferencesHandlesUnknownAPIError() async {
        notifRepo.getPreferencesResult = .failure(APIError.unknown(status: 418))
        let sut = makeSUT()
        await sut.loadPreferences()
        #expect(sut.error == "Failed to load notification preferences")
    }

    // MARK: - Has Changes

    @Test func hasChangesReturnsFalseAfterLoad() async {
        let sut = makeSUT()
        await sut.loadPreferences()
        #expect(!sut.hasChanges)
    }

    @Test func hasChangesDetectsReportUploadedPushChange() async {
        let sut = makeSUT()
        await sut.loadPreferences()
        sut.reportUploaded.push = !sut.reportUploaded.push
        #expect(sut.hasChanges)
    }

    @Test func hasChangesDetectsReportUploadedEmailChange() async {
        let sut = makeSUT()
        await sut.loadPreferences()
        sut.reportUploaded.email = !sut.reportUploaded.email
        #expect(sut.hasChanges)
    }

    @Test func hasChangesDetectsReportUploadedSmsChange() async {
        let sut = makeSUT()
        await sut.loadPreferences()
        sut.reportUploaded.sms = !sut.reportUploaded.sms
        #expect(sut.hasChanges)
    }

    @Test func hasChangesDetectsAccessGrantedPushChange() async {
        let sut = makeSUT()
        await sut.loadPreferences()
        sut.accessGranted.push = !sut.accessGranted.push
        #expect(sut.hasChanges)
    }

    @Test func hasChangesDetectsAccessGrantedEmailChange() async {
        let sut = makeSUT()
        await sut.loadPreferences()
        sut.accessGranted.email = !sut.accessGranted.email
        #expect(sut.hasChanges)
    }

    @Test func hasChangesDetectsAccessGrantedSmsChange() async {
        let sut = makeSUT()
        await sut.loadPreferences()
        sut.accessGranted.sms = !sut.accessGranted.sms
        #expect(sut.hasChanges)
    }

    @Test func hasChangesDetectsEmergencyAccessPushChange() async {
        let sut = makeSUT()
        await sut.loadPreferences()
        sut.emergencyAccess.push = !sut.emergencyAccess.push
        #expect(sut.hasChanges)
    }

    @Test func hasChangesDetectsEmergencyAccessEmailChange() async {
        let sut = makeSUT()
        await sut.loadPreferences()
        sut.emergencyAccess.email = !sut.emergencyAccess.email
        #expect(sut.hasChanges)
    }

    @Test func hasChangesDetectsEmergencyAccessSmsChange() async {
        let sut = makeSUT()
        await sut.loadPreferences()
        sut.emergencyAccess.sms = !sut.emergencyAccess.sms
        #expect(sut.hasChanges)
    }

    @Test func hasChangesReturnsFalseAfterRevertingChange() async {
        let sut = makeSUT()
        await sut.loadPreferences()
        let original = sut.reportUploaded.push
        sut.reportUploaded.push = !original
        #expect(sut.hasChanges)
        sut.reportUploaded.push = original
        #expect(!sut.hasChanges)
    }

    // MARK: - Save Preferences

    @Test func savePreferencesCallsRepository() async {
        let sut = makeSUT()
        await sut.loadPreferences()
        sut.reportUploaded.push = false
        await sut.savePreferences()
        #expect(notifRepo.updatePreferencesCallCount == 1)
    }

    @Test func savePreferencesSendsCurrentValues() async {
        let sut = makeSUT()
        await sut.loadPreferences()
        sut.reportUploaded.push = false
        sut.accessGranted.email = true
        sut.emergencyAccess.sms = false
        await sut.savePreferences()

        let sent = notifRepo.lastUpdatedPreferences
        #expect(sent?.reportUploaded.push == false)
        #expect(sent?.accessGranted.email == true)
        #expect(sent?.emergencyAccess.sms == false)
    }

    @Test func savePreferencesSetsSaveSuccess() async {
        let sut = makeSUT()
        await sut.loadPreferences()
        sut.reportUploaded.push = false
        await sut.savePreferences()
        #expect(sut.saveSuccess)
        #expect(sut.error == nil)
    }

    @Test func savePreferencesUpdatesOriginalPreferences() async {
        let updatedPrefs = NotificationPreferences(
            reportUploaded: ChannelPreferences(push: false, email: false, sms: true),
            accessGranted: ChannelPreferences(push: false, email: true, sms: false),
            emergencyAccess: ChannelPreferences(push: true, email: false, sms: true)
        )
        notifRepo.updatePreferencesResult = .success(updatedPrefs)
        let sut = makeSUT()
        await sut.loadPreferences()
        sut.reportUploaded.push = false
        await sut.savePreferences()

        // After save, values should match server response
        #expect(sut.reportUploaded == updatedPrefs.reportUploaded)
        #expect(sut.accessGranted == updatedPrefs.accessGranted)
        #expect(sut.emergencyAccess == updatedPrefs.emergencyAccess)
        #expect(!sut.hasChanges)
    }

    @Test func savePreferencesSetsIsSavingFalseAfterCompletion() async {
        let sut = makeSUT()
        await sut.loadPreferences()
        sut.reportUploaded.push = false
        await sut.savePreferences()
        #expect(!sut.isSaving)
    }

    @Test func savePreferencesClearsErrorOnNewAttempt() async {
        notifRepo.updatePreferencesResult = .failure(APIError.serverError(status: 500))
        let sut = makeSUT()
        await sut.loadPreferences()
        sut.reportUploaded.push = false
        await sut.savePreferences()
        #expect(sut.error != nil)

        notifRepo.updatePreferencesResult = .success(.stub)
        await sut.savePreferences()
        #expect(sut.error == nil)
    }

    @Test func savePreferencesClearsPreviousSuccessOnNewAttempt() async {
        let sut = makeSUT()
        await sut.loadPreferences()
        sut.reportUploaded.push = false
        await sut.savePreferences()
        #expect(sut.saveSuccess)

        notifRepo.updatePreferencesResult = .failure(APIError.serverError(status: 500))
        await sut.savePreferences()
        #expect(!sut.saveSuccess)
    }

    // MARK: - Save Error Handling

    @Test func savePreferencesHandlesServerError() async {
        notifRepo.updatePreferencesResult = .failure(APIError.serverError(status: 500))
        let sut = makeSUT()
        await sut.loadPreferences()
        sut.reportUploaded.push = false
        await sut.savePreferences()
        #expect(sut.error == "Server error. Please try again later.")
        #expect(!sut.saveSuccess)
    }

    @Test func savePreferencesHandlesNetworkError() async {
        notifRepo.updatePreferencesResult = .failure(
            APIError.networkError(underlying: URLError(.notConnectedToInternet))
        )
        let sut = makeSUT()
        await sut.loadPreferences()
        sut.reportUploaded.push = false
        await sut.savePreferences()
        #expect(sut.error == "Network error. Check your connection and try again.")
    }

    @Test func savePreferencesHandlesUnauthorizedError() async {
        notifRepo.updatePreferencesResult = .failure(APIError.unauthorized)
        let sut = makeSUT()
        await sut.loadPreferences()
        sut.reportUploaded.push = false
        await sut.savePreferences()
        #expect(sut.error == "Session expired. Please sign in again.")
    }

    @Test func savePreferencesHandlesTokenRefreshFailed() async {
        notifRepo.updatePreferencesResult = .failure(APIError.tokenRefreshFailed)
        let sut = makeSUT()
        await sut.loadPreferences()
        sut.reportUploaded.push = false
        await sut.savePreferences()
        #expect(sut.error == "Session expired. Please sign in again.")
    }

    @Test func savePreferencesHandlesRateLimited() async {
        notifRepo.updatePreferencesResult = .failure(APIError.rateLimited(retryAfter: 30))
        let sut = makeSUT()
        await sut.loadPreferences()
        sut.reportUploaded.push = false
        await sut.savePreferences()
        #expect(sut.error == "Too many requests. Please try again later.")
    }

    @Test func savePreferencesHandlesUnknownAPIError() async {
        notifRepo.updatePreferencesResult = .failure(APIError.unknown(status: 418))
        let sut = makeSUT()
        await sut.loadPreferences()
        sut.reportUploaded.push = false
        await sut.savePreferences()
        #expect(sut.error == "Failed to save preferences")
    }

    @Test func savePreferencesHandlesNonAPIError() async {
        struct CustomError: Error {}
        notifRepo.updatePreferencesResult = .failure(CustomError())
        let sut = makeSUT()
        await sut.loadPreferences()
        sut.reportUploaded.push = false
        await sut.savePreferences()
        #expect(sut.error == "Failed to save preferences")
        #expect(!sut.saveSuccess)
    }

    @Test func savePreferencesSetsIsSavingFalseAfterFailure() async {
        notifRepo.updatePreferencesResult = .failure(APIError.serverError(status: 500))
        let sut = makeSUT()
        await sut.loadPreferences()
        sut.reportUploaded.push = false
        await sut.savePreferences()
        #expect(!sut.isSaving)
    }

    // MARK: - Dismiss

    @Test func dismissSaveSuccessClearsFlag() async {
        let sut = makeSUT()
        await sut.loadPreferences()
        sut.reportUploaded.push = false
        await sut.savePreferences()
        #expect(sut.saveSuccess)
        sut.dismissSaveSuccess()
        #expect(!sut.saveSuccess)
    }

    @Test func dismissErrorClearsError() async {
        notifRepo.getPreferencesResult = .failure(APIError.serverError(status: 500))
        let sut = makeSUT()
        await sut.loadPreferences()
        #expect(sut.error != nil)
        sut.dismissError()
        #expect(sut.error == nil)
    }

    // MARK: - Current Preferences

    @Test func currentPreferencesReflectsViewModelState() async {
        let sut = makeSUT()
        await sut.loadPreferences()
        sut.reportUploaded = ChannelPreferences(push: false, email: false, sms: true)
        sut.accessGranted = ChannelPreferences(push: true, email: true, sms: true)
        sut.emergencyAccess = ChannelPreferences(push: false, email: true, sms: false)

        let current = sut.currentPreferences
        #expect(current.reportUploaded == sut.reportUploaded)
        #expect(current.accessGranted == sut.accessGranted)
        #expect(current.emergencyAccess == sut.emergencyAccess)
    }

    // MARK: - Multiple Operations

    @Test func loadAfterSaveResetsSuccessState() async {
        let sut = makeSUT()
        await sut.loadPreferences()
        sut.reportUploaded.push = false
        await sut.savePreferences()
        #expect(sut.saveSuccess)

        // Loading again should not clear saveSuccess (separate operation)
        await sut.loadPreferences()
        #expect(sut.saveSuccess)
        #expect(notifRepo.getPreferencesCallCount == 2)
    }

    @Test func multipleSavesTrackCallCount() async {
        let sut = makeSUT()
        await sut.loadPreferences()
        sut.reportUploaded.push = false
        await sut.savePreferences()
        await sut.savePreferences()
        #expect(notifRepo.updatePreferencesCallCount == 2)
    }
}
