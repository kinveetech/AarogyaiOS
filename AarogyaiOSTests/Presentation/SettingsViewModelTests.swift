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
            manageConsentsUseCase: ManageConsentsUseCase(consentRepository: consentRepo),
            manageNotificationsUseCase: ManageNotificationsUseCase(notificationRepository: notifRepo),
            logoutUseCase: LogoutUseCase(authRepository: authRepo, tokenStore: tokenStore),
            exportDataUseCase: ExportDataUseCase(userRepository: userRepo),
            requestAccountDeletionUseCase: RequestAccountDeletionUseCase(userRepository: userRepo),
            onSignOut: {}
        )
    }

    @Test func exportDataSuccess() async {
        let sut = makeSUT()
        await sut.exportData()
        #expect(userRepo.exportDataCallCount == 1)
        #expect(!sut.isExporting)
        #expect(sut.error == nil)
    }

    @Test func exportDataFailure() async {
        userRepo.exportDataResult = .failure(APIError.serverError(status: 500))
        let sut = makeSUT()
        await sut.exportData()
        #expect(sut.error == "Failed to export data")
    }

    @Test func requestAccountDeletion() async {
        let sut = makeSUT()
        await sut.requestAccountDeletion()
        #expect(userRepo.requestDeletionCallCount == 1)
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

    @Test func loadProfilePopulatesFields() async {
        let sut = makeSUT()
        await sut.loadProfile()
        #expect(sut.firstName == "Test")
        #expect(sut.lastName == "User")
        #expect(sut.email == "test@example.com")
        #expect(!sut.isLoading)
    }

    @Test func hasChangesDetectsModification() async {
        let sut = makeSUT()
        await sut.loadProfile()
        #expect(!sut.hasChanges)

        sut.firstName = "Modified"
        #expect(sut.hasChanges)
    }

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

    @Test func saveProfileFailureSetsError() async {
        userRepo.updateProfileResult = .failure(APIError.serverError(status: 500))
        let sut = makeSUT()
        await sut.loadProfile()
        sut.firstName = "Updated"
        await sut.saveProfile()
        #expect(sut.error == "Failed to save profile")
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

@Suite("NotificationPreferencesViewModel")
@MainActor
struct NotificationPreferencesViewModelTests {
    let notifRepo = MockNotificationRepository()

    func makeSUT() -> NotificationPreferencesViewModel {
        NotificationPreferencesViewModel(
            manageNotificationsUseCase: ManageNotificationsUseCase(notificationRepository: notifRepo)
        )
    }

    @Test func loadPreferencesSuccess() async {
        let sut = makeSUT()
        await sut.loadPreferences()
        #expect(sut.reportUploaded.push)
        #expect(!sut.isLoading)
        #expect(sut.error == nil)
    }

    @Test func hasChangesDetectsModification() async {
        let sut = makeSUT()
        await sut.loadPreferences()
        #expect(!sut.hasChanges)

        sut.reportUploaded.push = false
        #expect(sut.hasChanges)
    }

    @Test func savePreferencesCallsRepository() async {
        let sut = makeSUT()
        await sut.loadPreferences()
        sut.reportUploaded.push = false
        await sut.savePreferences()
        #expect(notifRepo.updatePreferencesCallCount == 1)
    }
}
