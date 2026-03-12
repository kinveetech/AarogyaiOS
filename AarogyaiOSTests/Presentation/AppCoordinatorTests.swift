import Foundation
import Testing
@testable import AarogyaiOS

@Suite("AppCoordinator")
@MainActor
struct AppCoordinatorTests {
    let userRepo = MockUserRepository()
    let authRepo = MockAuthRepository()
    let tokenStore = MockTokenStore()
    let deviceTokenManager = MockDeviceTokenManager()

    func makeSUT() -> AppCoordinator {
        AppCoordinator(
            getCurrentUser: GetCurrentUserUseCase(userRepository: userRepo),
            logout: LogoutUseCase(authRepository: authRepo, tokenStore: tokenStore),
            deviceTokenManager: deviceTokenManager
        )
    }

    // MARK: - checkAuthState

    @Test func checkAuthStateWithApprovedUserSetsAuthenticated() async {
        let sut = makeSUT()
        await sut.checkAuthState()
        if case .authenticated(let user) = sut.state {
            #expect(user.id == "user-1")
        } else {
            Issue.record("Expected .authenticated, got \(sut.state)")
        }
    }

    @Test func checkAuthStateWithPendingApprovalUserSetsPendingApproval() async {
        userRepo.getProfileResult = .success(User.stub(registrationStatus: .pendingApproval))
        let sut = makeSUT()
        await sut.checkAuthState()
        if case .pendingApproval = sut.state {
            // pass
        } else {
            Issue.record("Expected .pendingApproval, got \(sut.state)")
        }
    }

    @Test func checkAuthStateWithRegisteredUserSetsPendingApproval() async {
        userRepo.getProfileResult = .success(User.stub(registrationStatus: .registered))
        let sut = makeSUT()
        await sut.checkAuthState()
        if case .pendingApproval = sut.state {
            // pass
        } else {
            Issue.record("Expected .pendingApproval, got \(sut.state)")
        }
    }

    @Test func checkAuthStateWithRejectedUserSetsRejected() async {
        userRepo.getProfileResult = .success(User.stub(registrationStatus: .rejected))
        let sut = makeSUT()
        await sut.checkAuthState()
        if case .rejected = sut.state {
            // pass
        } else {
            Issue.record("Expected .rejected, got \(sut.state)")
        }
    }

    @Test func checkAuthStateWithUnauthorizedSetsUnauthenticated() async {
        userRepo.getProfileResult = .failure(APIError.unauthorized)
        let sut = makeSUT()
        await sut.checkAuthState()
        if case .unauthenticated = sut.state {
            // pass
        } else {
            Issue.record("Expected .unauthenticated, got \(sut.state)")
        }
    }

    @Test func checkAuthStateWithTokenRefreshFailedSetsUnauthenticated() async {
        userRepo.getProfileResult = .failure(APIError.tokenRefreshFailed)
        let sut = makeSUT()
        await sut.checkAuthState()
        if case .unauthenticated = sut.state {
            // pass
        } else {
            Issue.record("Expected .unauthenticated, got \(sut.state)")
        }
    }

    @Test func checkAuthStateWithRegistrationRequiredSetsRegistration() async {
        userRepo.getProfileResult = .failure(APIError.registrationRequired)
        let sut = makeSUT()
        await sut.checkAuthState()
        if case .registration = sut.state {
            // pass
        } else {
            Issue.record("Expected .registration, got \(sut.state)")
        }
    }

    @Test func checkAuthStateWithRegistrationPendingSetsPendingApproval() async {
        userRepo.getProfileResult = .failure(APIError.registrationPending)
        let sut = makeSUT()
        await sut.checkAuthState()
        if case .pendingApproval = sut.state {
            // pass
        } else {
            Issue.record("Expected .pendingApproval, got \(sut.state)")
        }
    }

    @Test func checkAuthStateWithRegistrationRejectedSetsRejected() async {
        userRepo.getProfileResult = .failure(APIError.registrationRejected)
        let sut = makeSUT()
        await sut.checkAuthState()
        if case .rejected = sut.state {
            // pass
        } else {
            Issue.record("Expected .rejected, got \(sut.state)")
        }
    }

    @Test func checkAuthStateWithUnknownAPIErrorSetsUnauthenticated() async {
        userRepo.getProfileResult = .failure(APIError.serverError(status: 500))
        let sut = makeSUT()
        await sut.checkAuthState()
        if case .unauthenticated = sut.state {
            // pass
        } else {
            Issue.record("Expected .unauthenticated, got \(sut.state)")
        }
    }

    @Test func checkAuthStateWithNonAPIErrorSetsUnauthenticated() async {
        userRepo.getProfileResult = .failure(URLError(.notConnectedToInternet))
        let sut = makeSUT()
        await sut.checkAuthState()
        if case .unauthenticated = sut.state {
            // pass
        } else {
            Issue.record("Expected .unauthenticated, got \(sut.state)")
        }
    }

    // MARK: - handleLogin

    @Test func handleLoginCallsCheckAuthState() async {
        let sut = makeSUT()
        await sut.handleLogin()
        #expect(userRepo.getProfileCallCount == 1)
    }

    // MARK: - handleLogout

    @Test func handleLogoutSetsUnauthenticated() async {
        let sut = makeSUT()
        sut.state = .authenticated(.stub)
        await sut.handleLogout()
        if case .unauthenticated = sut.state {
            // pass
        } else {
            Issue.record("Expected .unauthenticated, got \(sut.state)")
        }
    }

    @Test func handleLogoutClearsTokens() async {
        let sut = makeSUT()
        await sut.handleLogout()
        #expect(tokenStore.clearAllCallCount == 1)
    }

    // MARK: - handleRegistrationComplete

    @Test func handleRegistrationCompleteRechecksAuthState() async {
        let sut = makeSUT()
        await sut.handleRegistrationComplete()
        #expect(userRepo.getProfileCallCount == 1)
    }

    // MARK: - Deep Links

    @Test func handleDeepLinkWhenAuthenticatedAppliesImmediately() {
        let sut = makeSUT()
        sut.state = .authenticated(.stub)
        sut.handleDeepLink(.settings)
        #expect(sut.selectedTab == .settings)
        #expect(sut.pendingDeepLink == nil)
    }

    @Test func handleDeepLinkWhenUnauthenticatedStoresPending() {
        let sut = makeSUT()
        sut.state = .unauthenticated
        sut.handleDeepLink(.settings)
        #expect(sut.pendingDeepLink != nil)
    }

    @Test func consumePendingDeepLinkAppliesAndClears() {
        let sut = makeSUT()
        sut.state = .authenticated(.stub)
        sut.pendingDeepLink = .emergency
        sut.consumePendingDeepLink()
        #expect(sut.selectedTab == .emergency)
        #expect(sut.pendingDeepLink == nil)
    }

    @Test func consumePendingDeepLinkWithNoPendingDoesNothing() {
        let sut = makeSUT()
        sut.state = .authenticated(.stub)
        let originalTab = sut.selectedTab
        sut.consumePendingDeepLink()
        #expect(sut.selectedTab == originalTab)
    }

    // MARK: - Device Token Registration

    @Test func checkAuthStateReregistersDeviceTokenOnAuthenticated() async {
        let sut = makeSUT()
        await sut.checkAuthState()
        #expect(deviceTokenManager.reregisterIfNeededCallCount == 1)
    }

    @Test func checkAuthStateDoesNotReregisterOnPendingApproval() async {
        userRepo.getProfileResult = .success(User.stub(registrationStatus: .pendingApproval))
        let sut = makeSUT()
        await sut.checkAuthState()
        #expect(deviceTokenManager.reregisterIfNeededCallCount == 0)
    }

    @Test func checkAuthStateDoesNotReregisterOnRejected() async {
        userRepo.getProfileResult = .success(User.stub(registrationStatus: .rejected))
        let sut = makeSUT()
        await sut.checkAuthState()
        #expect(deviceTokenManager.reregisterIfNeededCallCount == 0)
    }

    @Test func checkAuthStateDoesNotReregisterOnUnauthorized() async {
        userRepo.getProfileResult = .failure(APIError.unauthorized)
        let sut = makeSUT()
        await sut.checkAuthState()
        #expect(deviceTokenManager.reregisterIfNeededCallCount == 0)
    }

    @Test func handleLogoutUnregistersDeviceToken() async {
        let sut = makeSUT()
        sut.state = .authenticated(.stub)
        await sut.handleLogout()
        #expect(deviceTokenManager.unregisterCurrentDeviceCallCount == 1)
    }

    @Test func handleLogoutUnregistersDeviceTokenBeforeClearingTokens() async {
        // The device token unregistration requires an auth token,
        // so it must happen before logout clears the token store.
        let sut = makeSUT()
        sut.state = .authenticated(.stub)
        await sut.handleLogout()
        #expect(deviceTokenManager.unregisterCurrentDeviceCallCount == 1)
        #expect(tokenStore.clearAllCallCount == 1)
    }

    @Test func handleLoginTriggersReregistration() async {
        let sut = makeSUT()
        await sut.handleLogin()
        // handleLogin calls checkAuthState which reregisters on success
        #expect(deviceTokenManager.reregisterIfNeededCallCount == 1)
    }
}
