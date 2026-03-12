import Foundation
import Synchronization
import Testing
@testable import AarogyaiOS

@Suite("SettingsViewModel")
@MainActor
struct SettingsViewModelTests {
    let userRepo = MockUserRepository()
    let consentRepo = MockConsentRepository()
    let notifRepo = MockNotificationRepository()
    let authRepo = MockAuthRepository()
    let tokenStore = MockTokenStore()

    func makeSUT(signOutCalled: (@Sendable () -> Void)? = nil) -> SettingsViewModel {
        SettingsViewModel(
            getCurrentUserUseCase: GetCurrentUserUseCase(userRepository: userRepo),
            updateProfileUseCase: UpdateProfileUseCase(userRepository: userRepo),
            verifyAadhaarUseCase: VerifyAadhaarUseCase(userRepository: userRepo),
            manageConsentsUseCase: ManageConsentsUseCase(consentRepository: consentRepo),
            manageNotificationsUseCase: ManageNotificationsUseCase(notificationRepository: notifRepo),
            deviceTokenManager: MockDeviceTokenManager(),
            logoutUseCase: LogoutUseCase(authRepository: authRepo, tokenStore: tokenStore),
            exportDataUseCase: ExportDataUseCase(userRepository: userRepo),
            requestAccountDeletionUseCase: RequestAccountDeletionUseCase(userRepository: userRepo),
            onSignOut: { signOutCalled?() }
        )
    }

    // MARK: - Export Data Confirmation

    @Test func confirmExportDataShowsConfirmation() {
        let sut = makeSUT()
        #expect(!sut.showExportConfirmation)
        sut.confirmExportData()
        #expect(sut.showExportConfirmation)
    }

    // MARK: - Export Data Success

    @Test func exportDataSuccessSetsExportSuccess() async {
        let sut = makeSUT()
        await sut.exportData()
        #expect(userRepo.exportDataCallCount == 1)
        #expect(!sut.isExporting)
        #expect(sut.exportSuccess)
        #expect(sut.error == nil)
    }

    @Test func exportDataClearsErrorOnNewAttempt() async {
        userRepo.exportDataResult = .failure(APIError.serverError(status: 500))
        let sut = makeSUT()
        await sut.exportData()
        #expect(sut.error != nil)

        userRepo.exportDataResult = .success(())
        await sut.exportData()
        #expect(sut.error == nil)
        #expect(sut.exportSuccess)
    }

    @Test func exportDataClearsPreviousSuccessOnNewAttempt() async {
        let sut = makeSUT()
        await sut.exportData()
        #expect(sut.exportSuccess)

        userRepo.exportDataResult = .failure(APIError.serverError(status: 500))
        await sut.exportData()
        #expect(!sut.exportSuccess)
    }

    @Test func exportDataSetsIsExportingFalseAfterCompletion() async {
        let sut = makeSUT()
        await sut.exportData()
        #expect(!sut.isExporting)
    }

    // MARK: - Export Data Error Handling

    @Test func exportDataHandlesServerError() async {
        userRepo.exportDataResult = .failure(APIError.serverError(status: 500))
        let sut = makeSUT()
        await sut.exportData()
        #expect(sut.error == "Server error. Please try again later.")
        #expect(!sut.exportSuccess)
    }

    @Test func exportDataHandlesNetworkError() async {
        userRepo.exportDataResult = .failure(
            APIError.networkError(underlying: URLError(.notConnectedToInternet))
        )
        let sut = makeSUT()
        await sut.exportData()
        #expect(sut.error == "Network error. Check your connection and try again.")
    }

    @Test func exportDataHandlesUnauthorizedError() async {
        userRepo.exportDataResult = .failure(APIError.unauthorized)
        let sut = makeSUT()
        await sut.exportData()
        #expect(sut.error == "Session expired. Please sign in again.")
    }

    @Test func exportDataHandlesTokenRefreshFailed() async {
        userRepo.exportDataResult = .failure(APIError.tokenRefreshFailed)
        let sut = makeSUT()
        await sut.exportData()
        #expect(sut.error == "Session expired. Please sign in again.")
    }

    @Test func exportDataHandlesRateLimited() async {
        userRepo.exportDataResult = .failure(APIError.rateLimited(retryAfter: 60))
        let sut = makeSUT()
        await sut.exportData()
        #expect(sut.error == "Too many requests. Please try again later.")
    }

    @Test func exportDataHandlesUnknownAPIError() async {
        userRepo.exportDataResult = .failure(APIError.unknown(status: 418))
        let sut = makeSUT()
        await sut.exportData()
        #expect(sut.error == "Failed to export data. Please try again.")
    }

    @Test func exportDataHandlesNonAPIError() async {
        struct CustomError: Error {}
        userRepo.exportDataResult = .failure(CustomError())
        let sut = makeSUT()
        await sut.exportData()
        #expect(sut.error == "Failed to export data. Please try again.")
        #expect(!sut.exportSuccess)
    }

    // MARK: - Dismiss Export Success

    @Test func dismissExportSuccessClearsFlag() async {
        let sut = makeSUT()
        await sut.exportData()
        #expect(sut.exportSuccess)
        sut.dismissExportSuccess()
        #expect(!sut.exportSuccess)
    }

    // MARK: - Account Deletion: Step 1 — Initial Warning

    @Test func beginAccountDeletionShowsConfirmation() {
        let sut = makeSUT()
        #expect(!sut.showDeleteConfirmation)
        sut.beginAccountDeletion()
        #expect(sut.showDeleteConfirmation)
    }

    // MARK: - Account Deletion: Step 2 — Typing Confirmation

    @Test func proceedToDeleteTypingConfirmationShowsSheet() {
        let sut = makeSUT()
        sut.proceedToDeleteTypingConfirmation()
        #expect(sut.showDeleteTypingConfirmation)
        #expect(sut.deleteConfirmationText.isEmpty)
    }

    @Test func proceedToDeleteTypingConfirmationResetsText() {
        let sut = makeSUT()
        sut.deleteConfirmationText = "something"
        sut.proceedToDeleteTypingConfirmation()
        #expect(sut.deleteConfirmationText.isEmpty)
    }

    @Test func isDeleteConfirmationValidReturnsFalseWhenEmpty() {
        let sut = makeSUT()
        #expect(!sut.isDeleteConfirmationValid)
    }

    @Test func isDeleteConfirmationValidReturnsFalseForPartialText() {
        let sut = makeSUT()
        sut.deleteConfirmationText = "DEL"
        #expect(!sut.isDeleteConfirmationValid)
    }

    @Test func isDeleteConfirmationValidReturnsFalseForWrongText() {
        let sut = makeSUT()
        sut.deleteConfirmationText = "REMOVE"
        #expect(!sut.isDeleteConfirmationValid)
    }

    @Test func isDeleteConfirmationValidReturnsTrueForExactMatch() {
        let sut = makeSUT()
        sut.deleteConfirmationText = "DELETE"
        #expect(sut.isDeleteConfirmationValid)
    }

    @Test func isDeleteConfirmationValidIsCaseInsensitive() {
        let sut = makeSUT()
        sut.deleteConfirmationText = "delete"
        #expect(sut.isDeleteConfirmationValid)
    }

    @Test func isDeleteConfirmationValidTrimsWhitespace() {
        let sut = makeSUT()
        sut.deleteConfirmationText = "  DELETE  "
        #expect(sut.isDeleteConfirmationValid)
    }

    @Test func isDeleteConfirmationValidHandlesMixedCase() {
        let sut = makeSUT()
        sut.deleteConfirmationText = "Delete"
        #expect(sut.isDeleteConfirmationValid)
    }

    // MARK: - Account Deletion: Confirm and Execute

    @Test func confirmAccountDeletionCallsRepository() async {
        let sut = makeSUT()
        sut.deleteConfirmationText = "DELETE"
        await sut.confirmAccountDeletion()
        #expect(userRepo.requestDeletionCallCount == 1)
    }

    @Test func confirmAccountDeletionDoesNothingWhenTextInvalid() async {
        let sut = makeSUT()
        sut.deleteConfirmationText = "WRONG"
        await sut.confirmAccountDeletion()
        #expect(userRepo.requestDeletionCallCount == 0)
    }

    @Test func confirmAccountDeletionSignsOutOnSuccess() async {
        let signedOut = Mutex(false)
        let sut = makeSUT(signOutCalled: { signedOut.withLock { $0 = true } })
        sut.deleteConfirmationText = "DELETE"
        await sut.confirmAccountDeletion()
        #expect(signedOut.withLock { $0 })
    }

    @Test func confirmAccountDeletionClearsSheetOnSuccess() async {
        let sut = makeSUT()
        sut.showDeleteTypingConfirmation = true
        sut.deleteConfirmationText = "DELETE"
        await sut.confirmAccountDeletion()
        #expect(!sut.showDeleteTypingConfirmation)
        #expect(sut.deleteConfirmationText.isEmpty)
    }

    @Test func confirmAccountDeletionSetsIsDeletingFalseAfterSuccess() async {
        let sut = makeSUT()
        sut.deleteConfirmationText = "DELETE"
        await sut.confirmAccountDeletion()
        #expect(!sut.isDeletingAccount)
    }

    @Test func confirmAccountDeletionClearsErrorOnNewAttempt() async {
        userRepo.requestDeletionResult = .failure(APIError.serverError(status: 500))
        let sut = makeSUT()
        sut.deleteConfirmationText = "DELETE"
        await sut.confirmAccountDeletion()
        #expect(sut.error != nil)

        userRepo.requestDeletionResult = .success(())
        await sut.confirmAccountDeletion()
        #expect(sut.error == nil)
    }

    // MARK: - Account Deletion: Error Handling

    @Test func confirmAccountDeletionSetsErrorOnFailure() async {
        userRepo.requestDeletionResult = .failure(APIError.serverError(status: 500))
        let sut = makeSUT()
        sut.deleteConfirmationText = "DELETE"
        await sut.confirmAccountDeletion()
        #expect(sut.error == "Server error. Please try again later.")
    }

    @Test func confirmAccountDeletionDoesNotSignOutOnFailure() async {
        let signedOut = Mutex(false)
        userRepo.requestDeletionResult = .failure(APIError.serverError(status: 500))
        let sut = makeSUT(signOutCalled: { signedOut.withLock { $0 = true } })
        sut.deleteConfirmationText = "DELETE"
        await sut.confirmAccountDeletion()
        #expect(!signedOut.withLock { $0 })
    }

    @Test func confirmAccountDeletionSetsIsDeletingFalseAfterFailure() async {
        userRepo.requestDeletionResult = .failure(APIError.serverError(status: 500))
        let sut = makeSUT()
        sut.deleteConfirmationText = "DELETE"
        await sut.confirmAccountDeletion()
        #expect(!sut.isDeletingAccount)
    }

    @Test func confirmAccountDeletionHandlesDeletionAlreadyPending() async {
        userRepo.requestDeletionResult = .failure(APIError.deletionAlreadyPending)
        let sut = makeSUT()
        sut.deleteConfirmationText = "DELETE"
        await sut.confirmAccountDeletion()
        #expect(sut.error == "A deletion request is already pending. Please wait for it to be processed.")
    }

    @Test func confirmAccountDeletionHandlesUnauthorizedError() async {
        userRepo.requestDeletionResult = .failure(APIError.unauthorized)
        let sut = makeSUT()
        sut.deleteConfirmationText = "DELETE"
        await sut.confirmAccountDeletion()
        #expect(sut.error == "Session expired. Please sign in again.")
    }

    @Test func confirmAccountDeletionHandlesTokenRefreshFailed() async {
        userRepo.requestDeletionResult = .failure(APIError.tokenRefreshFailed)
        let sut = makeSUT()
        sut.deleteConfirmationText = "DELETE"
        await sut.confirmAccountDeletion()
        #expect(sut.error == "Session expired. Please sign in again.")
    }

    @Test func confirmAccountDeletionHandlesRateLimited() async {
        userRepo.requestDeletionResult = .failure(APIError.rateLimited(retryAfter: 30))
        let sut = makeSUT()
        sut.deleteConfirmationText = "DELETE"
        await sut.confirmAccountDeletion()
        #expect(sut.error == "Too many requests. Please try again later.")
    }

    @Test func confirmAccountDeletionHandlesNetworkError() async {
        userRepo.requestDeletionResult = .failure(
            APIError.networkError(underlying: URLError(.notConnectedToInternet))
        )
        let sut = makeSUT()
        sut.deleteConfirmationText = "DELETE"
        await sut.confirmAccountDeletion()
        #expect(sut.error == "Network error. Check your connection and try again.")
    }

    @Test func confirmAccountDeletionHandlesUnknownAPIError() async {
        userRepo.requestDeletionResult = .failure(APIError.unknown(status: 418))
        let sut = makeSUT()
        sut.deleteConfirmationText = "DELETE"
        await sut.confirmAccountDeletion()
        #expect(sut.error == "Failed to request account deletion. Please try again.")
    }

    @Test func confirmAccountDeletionHandlesNonAPIError() async {
        struct CustomError: Error {}
        userRepo.requestDeletionResult = .failure(CustomError())
        let sut = makeSUT()
        sut.deleteConfirmationText = "DELETE"
        await sut.confirmAccountDeletion()
        #expect(sut.error == "Failed to request account deletion. Please try again.")
    }

    // MARK: - Account Deletion: Cancel

    @Test func cancelAccountDeletionResetsState() {
        let sut = makeSUT()
        sut.showDeleteTypingConfirmation = true
        sut.deleteConfirmationText = "DELE"
        sut.cancelAccountDeletion()
        #expect(!sut.showDeleteTypingConfirmation)
        #expect(sut.deleteConfirmationText.isEmpty)
    }

    // MARK: - Account Deletion: Legacy Method

    @Test func requestAccountDeletionCallsConfirmAccountDeletion() async {
        let sut = makeSUT()
        sut.deleteConfirmationText = "DELETE"
        await sut.requestAccountDeletion()
        #expect(userRepo.requestDeletionCallCount == 1)
    }

    // MARK: - Account Deletion: Confirmation Keyword

    @Test func deletionConfirmationKeywordIsDELETE() {
        #expect(SettingsViewModel.deletionConfirmationKeyword == "DELETE")
    }

    // MARK: - Sign Out

    @Test func signOutCallsLogoutAndOnSignOut() async {
        let signedOut = Mutex(false)
        let sut = makeSUT(signOutCalled: { signedOut.withLock { $0 = true } })
        await sut.signOut()
        #expect(authRepo.revokeTokenCallCount == 1)
        #expect(tokenStore.clearAllCallCount == 1)
        #expect(signedOut.withLock { $0 })
    }

    @Test func signOutStillCallsOnSignOutWhenLogoutFails() async {
        let signedOut = Mutex(false)
        tokenStore.clearAllResult = .failure(APIError.networkError(underlying: URLError(.notConnectedToInternet)))
        let sut = makeSUT(signOutCalled: { signedOut.withLock { $0 = true } })
        await sut.signOut()
        #expect(signedOut.withLock { $0 })
    }
}

@Suite("ProfileEditViewModel")
@MainActor
struct ProfileEditViewModelTests {
    let userRepo = MockUserRepository()

    func makeSUT() -> ProfileEditViewModel {
        ProfileEditViewModel(
            getCurrentUserUseCase: GetCurrentUserUseCase(userRepository: userRepo),
            updateProfileUseCase: UpdateProfileUseCase(userRepository: userRepo)
        )
    }

    // MARK: - Load Profile

    @Test func loadProfilePopulatesFields() async {
        let sut = makeSUT()
        await sut.loadProfile()
        #expect(sut.firstName == "Test")
        #expect(sut.lastName == "User")
        #expect(sut.email == "test@example.com")
        #expect(sut.phone == "+911234567890")
        #expect(sut.bloodGroup == .oPositive)
        #expect(sut.gender == .male)
        #expect(sut.dateOfBirth == Date(timeIntervalSince1970: 946_684_800))
        #expect(!sut.isLoading)
        #expect(sut.error == nil)
    }

    @Test func loadProfileSetsLoadingState() async {
        let sut = makeSUT()
        #expect(!sut.isLoading)
        await sut.loadProfile()
        #expect(!sut.isLoading)
    }

    @Test func loadProfileFailureSetsError() async {
        userRepo.getProfileResult = .failure(APIError.networkError(underlying: URLError(.notConnectedToInternet)))
        let sut = makeSUT()
        await sut.loadProfile()
        #expect(sut.error == "Failed to load profile")
        #expect(!sut.isLoading)
    }

    @Test func loadProfilePopulatesAddress() async {
        var userWithAddress = User.stub
        userWithAddress.address = "123 Main St"
        userRepo.getProfileResult = .success(userWithAddress)
        let sut = makeSUT()
        await sut.loadProfile()
        #expect(sut.address == "123 Main St")
    }

    @Test func loadProfileHandlesNilOptionalFields() async {
        var userNoOptionals = User.stub
        userNoOptionals.bloodGroup = nil
        userNoOptionals.dateOfBirth = nil
        userNoOptionals.gender = nil
        userNoOptionals.address = nil
        userRepo.getProfileResult = .success(userNoOptionals)
        let sut = makeSUT()
        await sut.loadProfile()
        #expect(sut.bloodGroup == nil)
        #expect(sut.dateOfBirth == nil)
        #expect(sut.gender == nil)
        #expect(sut.address == nil)
    }

    // MARK: - Has Changes

    @Test func hasChangesReturnsFalseInitially() async {
        let sut = makeSUT()
        await sut.loadProfile()
        #expect(!sut.hasChanges)
    }

    @Test func hasChangesDetectsFirstNameChange() async {
        let sut = makeSUT()
        await sut.loadProfile()
        sut.firstName = "Modified"
        #expect(sut.hasChanges)
    }

    @Test func hasChangesDetectsLastNameChange() async {
        let sut = makeSUT()
        await sut.loadProfile()
        sut.lastName = "Modified"
        #expect(sut.hasChanges)
    }

    @Test func hasChangesDetectsBloodGroupChange() async {
        let sut = makeSUT()
        await sut.loadProfile()
        sut.bloodGroup = .abNegative
        #expect(sut.hasChanges)
    }

    @Test func hasChangesDetectsDateOfBirthChange() async {
        let sut = makeSUT()
        await sut.loadProfile()
        sut.dateOfBirth = Date(timeIntervalSince1970: 0)
        #expect(sut.hasChanges)
    }

    @Test func hasChangesDetectsGenderChange() async {
        let sut = makeSUT()
        await sut.loadProfile()
        sut.gender = .female
        #expect(sut.hasChanges)
    }

    @Test func hasChangesDetectsAddressChange() async {
        let sut = makeSUT()
        await sut.loadProfile()
        sut.address = "New Address"
        #expect(sut.hasChanges)
    }

    @Test func hasChangesReturnsFalseWithNoOriginalUser() {
        let sut = makeSUT()
        sut.firstName = "Something"
        #expect(!sut.hasChanges)
    }

    // MARK: - Validation

    @Test func validateFailsWhenFirstNameEmpty() async {
        let sut = makeSUT()
        await sut.loadProfile()
        sut.firstName = ""
        let result = sut.validate()
        #expect(!result)
        #expect(sut.validationErrors["firstName"] == "First name is required")
    }

    @Test func validateFailsWhenFirstNameWhitespaceOnly() async {
        let sut = makeSUT()
        await sut.loadProfile()
        sut.firstName = "   "
        let result = sut.validate()
        #expect(!result)
        #expect(sut.validationErrors["firstName"] == "First name is required")
    }

    @Test func validateFailsWhenFirstNameTooShort() async {
        let sut = makeSUT()
        await sut.loadProfile()
        sut.firstName = "A"
        let result = sut.validate()
        #expect(!result)
        #expect(sut.validationErrors["firstName"] == "First name must be at least 2 characters")
    }

    @Test func validateFailsWhenLastNameEmpty() async {
        let sut = makeSUT()
        await sut.loadProfile()
        sut.lastName = ""
        let result = sut.validate()
        #expect(!result)
        #expect(sut.validationErrors["lastName"] == "Last name is required")
    }

    @Test func validateFailsWhenLastNameWhitespaceOnly() async {
        let sut = makeSUT()
        await sut.loadProfile()
        sut.lastName = "   "
        let result = sut.validate()
        #expect(!result)
        #expect(sut.validationErrors["lastName"] == "Last name is required")
    }

    @Test func validateFailsWhenLastNameTooShort() async {
        let sut = makeSUT()
        await sut.loadProfile()
        sut.lastName = "B"
        let result = sut.validate()
        #expect(!result)
        #expect(sut.validationErrors["lastName"] == "Last name must be at least 2 characters")
    }

    @Test func validateFailsWhenDateOfBirthInFuture() async {
        let sut = makeSUT()
        await sut.loadProfile()
        sut.dateOfBirth = Date.now.addingTimeInterval(86400)
        let result = sut.validate()
        #expect(!result)
        #expect(sut.validationErrors["dateOfBirth"] == "Date of birth cannot be in the future")
    }

    @Test func validatePassesWithValidData() async {
        let sut = makeSUT()
        await sut.loadProfile()
        let result = sut.validate()
        #expect(result)
        #expect(sut.validationErrors.isEmpty)
    }

    @Test func validateCollectsMultipleErrors() async {
        let sut = makeSUT()
        await sut.loadProfile()
        sut.firstName = ""
        sut.lastName = ""
        sut.dateOfBirth = Date.now.addingTimeInterval(86400)
        let result = sut.validate()
        #expect(!result)
        #expect(sut.validationErrors.count == 3)
        #expect(sut.validationErrors["firstName"] != nil)
        #expect(sut.validationErrors["lastName"] != nil)
        #expect(sut.validationErrors["dateOfBirth"] != nil)
    }

    @Test func validateClearsPreviousErrors() async {
        let sut = makeSUT()
        await sut.loadProfile()
        sut.firstName = ""
        _ = sut.validate()
        #expect(sut.validationErrors["firstName"] != nil)

        sut.firstName = "Valid"
        let result = sut.validate()
        #expect(result)
        #expect(sut.validationErrors.isEmpty)
    }

    @Test func validateAcceptsNilDateOfBirth() async {
        var userNoDate = User.stub
        userNoDate.dateOfBirth = nil
        userRepo.getProfileResult = .success(userNoDate)
        let sut = makeSUT()
        await sut.loadProfile()
        let result = sut.validate()
        #expect(result)
        #expect(sut.validationErrors["dateOfBirth"] == nil)
    }

    // MARK: - Can Save

    @Test func canSaveReturnsFalseWithNoChanges() async {
        let sut = makeSUT()
        await sut.loadProfile()
        #expect(!sut.canSave)
    }

    @Test func canSaveReturnsTrueWithValidChanges() async {
        let sut = makeSUT()
        await sut.loadProfile()
        sut.firstName = "Updated"
        #expect(sut.canSave)
    }

    @Test func canSaveReturnsFalseWithValidationErrors() async {
        let sut = makeSUT()
        await sut.loadProfile()
        sut.firstName = ""
        _ = sut.validate()
        #expect(!sut.canSave)
    }

    @Test func canSaveReturnsFalseWhileSaving() async {
        let sut = makeSUT()
        await sut.loadProfile()
        sut.firstName = "Updated"
        // Manually set isSaving to simulate in-progress save
        sut.isSaving = true
        #expect(!sut.canSave)
    }

    // MARK: - Save Profile

    @Test func saveProfileCallsRepository() async {
        let updatedUser = User.stub
        userRepo.updateProfileResult = .success(updatedUser)
        let sut = makeSUT()
        await sut.loadProfile()
        sut.firstName = "Updated"
        await sut.saveProfile()
        #expect(userRepo.updateProfileCallCount == 1)
        #expect(userRepo.lastUpdatedUser?.firstName == "Updated")
    }

    @Test func saveProfileTrimsWhitespace() async {
        userRepo.updateProfileResult = .success(.stub)
        let sut = makeSUT()
        await sut.loadProfile()
        sut.firstName = "  Updated  "
        sut.lastName = "  Name  "
        sut.address = "  123 Main St  "
        await sut.saveProfile()
        #expect(userRepo.lastUpdatedUser?.firstName == "Updated")
        #expect(userRepo.lastUpdatedUser?.lastName == "Name")
        #expect(userRepo.lastUpdatedUser?.address == "123 Main St")
    }

    @Test func saveProfileSetsSaveSuccess() async {
        userRepo.updateProfileResult = .success(.stub)
        let sut = makeSUT()
        await sut.loadProfile()
        sut.firstName = "Updated"
        await sut.saveProfile()
        #expect(sut.saveSuccess)
        #expect(sut.error == nil)
    }

    @Test func saveProfileResetsSuccessOnNewSave() async {
        userRepo.updateProfileResult = .success(.stub)
        let sut = makeSUT()
        await sut.loadProfile()
        sut.firstName = "Updated"
        await sut.saveProfile()
        #expect(sut.saveSuccess)

        // Change again and save
        sut.firstName = "Another"
        userRepo.updateProfileResult = .failure(APIError.serverError(status: 500))
        await sut.saveProfile()
        #expect(!sut.saveSuccess)
    }

    @Test func saveProfileUpdatesOriginalUser() async {
        var updatedUser = User.stub
        updatedUser.firstName = "ServerName"
        userRepo.updateProfileResult = .success(updatedUser)
        let sut = makeSUT()
        await sut.loadProfile()
        sut.firstName = "Updated"
        await sut.saveProfile()
        // After save, fields should match server response
        #expect(sut.firstName == "ServerName")
        #expect(!sut.hasChanges)
    }

    @Test func saveProfileDoesNotCallRepositoryWhenNoOriginalUser() async {
        let sut = makeSUT()
        // Do not load profile
        await sut.saveProfile()
        #expect(userRepo.updateProfileCallCount == 0)
    }

    @Test func saveProfileDoesNotCallRepositoryWhenValidationFails() async {
        let sut = makeSUT()
        await sut.loadProfile()
        sut.firstName = ""
        await sut.saveProfile()
        #expect(userRepo.updateProfileCallCount == 0)
    }

    @Test func saveProfileClearsErrorOnNewAttempt() async {
        userRepo.updateProfileResult = .failure(APIError.serverError(status: 500))
        let sut = makeSUT()
        await sut.loadProfile()
        sut.firstName = "Updated"
        await sut.saveProfile()
        #expect(sut.error != nil)

        userRepo.updateProfileResult = .success(.stub)
        sut.firstName = "Updated2"
        await sut.saveProfile()
        #expect(sut.error == nil)
    }

    @Test func saveProfileSetsIsSavingFalseAfterCompletion() async {
        userRepo.updateProfileResult = .success(.stub)
        let sut = makeSUT()
        await sut.loadProfile()
        sut.firstName = "Updated"
        await sut.saveProfile()
        #expect(!sut.isSaving)
    }

    // MARK: - API Error Handling

    @Test func saveProfileHandlesServerError() async {
        userRepo.updateProfileResult = .failure(APIError.serverError(status: 500))
        let sut = makeSUT()
        await sut.loadProfile()
        sut.firstName = "Updated"
        await sut.saveProfile()
        #expect(sut.error == "Server error. Please try again later.")
        #expect(!sut.saveSuccess)
    }

    @Test func saveProfileHandlesNetworkError() async {
        userRepo.updateProfileResult = .failure(
            APIError.networkError(underlying: URLError(.notConnectedToInternet))
        )
        let sut = makeSUT()
        await sut.loadProfile()
        sut.firstName = "Updated"
        await sut.saveProfile()
        #expect(sut.error == "Network error. Check your connection and try again.")
    }

    @Test func saveProfileHandlesUnauthorizedError() async {
        userRepo.updateProfileResult = .failure(APIError.unauthorized)
        let sut = makeSUT()
        await sut.loadProfile()
        sut.firstName = "Updated"
        await sut.saveProfile()
        #expect(sut.error == "Session expired. Please sign in again.")
    }

    @Test func saveProfileHandlesTokenRefreshFailed() async {
        userRepo.updateProfileResult = .failure(APIError.tokenRefreshFailed)
        let sut = makeSUT()
        await sut.loadProfile()
        sut.firstName = "Updated"
        await sut.saveProfile()
        #expect(sut.error == "Session expired. Please sign in again.")
    }

    @Test func saveProfileHandlesValidationErrorFromAPI() async {
        userRepo.updateProfileResult = .failure(
            APIError.validationError(fields: [
                FieldError(field: "firstName", message: "Name contains invalid characters"),
                FieldError(field: "address", message: "Address is too long")
            ])
        )
        let sut = makeSUT()
        await sut.loadProfile()
        sut.firstName = "Updated"
        await sut.saveProfile()
        #expect(sut.validationErrors["firstName"] == "Name contains invalid characters")
        #expect(sut.validationErrors["address"] == "Address is too long")
        #expect(sut.error == nil)
    }

    @Test func saveProfileHandlesEmptyValidationErrorFromAPI() async {
        userRepo.updateProfileResult = .failure(APIError.validationError(fields: []))
        let sut = makeSUT()
        await sut.loadProfile()
        sut.firstName = "Updated"
        await sut.saveProfile()
        #expect(sut.error == "Validation failed")
    }

    @Test func saveProfileHandlesUnknownAPIError() async {
        userRepo.updateProfileResult = .failure(APIError.unknown(status: 418))
        let sut = makeSUT()
        await sut.loadProfile()
        sut.firstName = "Updated"
        await sut.saveProfile()
        #expect(sut.error == "Failed to save profile")
    }

    @Test func saveProfileHandlesNonAPIError() async {
        struct CustomError: Error {}
        userRepo.updateProfileResult = .failure(CustomError())
        let sut = makeSUT()
        await sut.loadProfile()
        sut.firstName = "Updated"
        await sut.saveProfile()
        #expect(sut.error == "Failed to save profile")
    }

    // MARK: - Clear Validation Error

    @Test func clearValidationErrorRemovesSpecificField() async {
        let sut = makeSUT()
        await sut.loadProfile()
        sut.firstName = ""
        sut.lastName = ""
        _ = sut.validate()
        #expect(sut.validationErrors.count == 2)

        sut.clearValidationError(for: "firstName")
        #expect(sut.validationErrors["firstName"] == nil)
        #expect(sut.validationErrors["lastName"] != nil)
    }

    @Test func clearValidationErrorNoOpForMissingField() {
        let sut = makeSUT()
        sut.clearValidationError(for: "nonexistent")
        #expect(sut.validationErrors.isEmpty)
    }

    // MARK: - Save Profile with Optional Fields

    @Test func saveProfileSendsBloodGroupChange() async {
        userRepo.updateProfileResult = .success(.stub)
        let sut = makeSUT()
        await sut.loadProfile()
        sut.bloodGroup = .abPositive
        await sut.saveProfile()
        #expect(userRepo.lastUpdatedUser?.bloodGroup == .abPositive)
    }

    @Test func saveProfileSendsGenderChange() async {
        userRepo.updateProfileResult = .success(.stub)
        let sut = makeSUT()
        await sut.loadProfile()
        sut.gender = .other
        await sut.saveProfile()
        #expect(userRepo.lastUpdatedUser?.gender == .other)
    }

    @Test func saveProfileSendsDateOfBirthChange() async {
        let newDate = Date(timeIntervalSince1970: 631_152_000)
        userRepo.updateProfileResult = .success(.stub)
        let sut = makeSUT()
        await sut.loadProfile()
        sut.dateOfBirth = newDate
        await sut.saveProfile()
        #expect(userRepo.lastUpdatedUser?.dateOfBirth == newDate)
    }

    @Test func saveProfileSendsNilAddress() async {
        var userWithAddress = User.stub
        userWithAddress.address = "Old Address"
        userRepo.getProfileResult = .success(userWithAddress)
        userRepo.updateProfileResult = .success(.stub)
        let sut = makeSUT()
        await sut.loadProfile()
        sut.address = nil
        await sut.saveProfile()
        #expect(userRepo.lastUpdatedUser?.address == nil)
    }

    @Test func saveProfileTrimsWhitespaceOnlyAddressToNil() async {
        var userWithAddress = User.stub
        userWithAddress.address = "Old Address"
        userRepo.getProfileResult = .success(userWithAddress)
        userRepo.updateProfileResult = .success(.stub)
        let sut = makeSUT()
        await sut.loadProfile()
        sut.address = "   "
        await sut.saveProfile()
        #expect(userRepo.lastUpdatedUser?.address == "")
    }
}

@Suite("ConsentsViewModel")
@MainActor
struct ConsentsViewModelTests {
    let consentRepo = MockConsentRepository()

    func makeSUT() -> ConsentsViewModel {
        ConsentsViewModel(manageConsentsUseCase: ManageConsentsUseCase(consentRepository: consentRepo))
    }

    @Test func loadConsentsPopulatesDefaults() async {
        let sut = makeSUT()
        await sut.loadConsents()
        #expect(sut.consents.count == ConsentPurpose.allCases.count)
    }

    @Test func isGrantedReturnsTrueForRequired() {
        let sut = makeSUT()
        #expect(sut.isGranted(.profileManagement))
    }

    @Test func toggleConsentCallsUseCase() async {
        let sut = makeSUT()
        await sut.toggleConsent(purpose: .medicalDataSharing, isGranted: true)
        #expect(consentRepo.upsertConsentCallCount == 1)
    }

    @Test func toggleConsentIgnoresRequired() async {
        let sut = makeSUT()
        await sut.toggleConsent(purpose: .profileManagement, isGranted: false)
        #expect(consentRepo.upsertConsentCallCount == 0)
    }
}

