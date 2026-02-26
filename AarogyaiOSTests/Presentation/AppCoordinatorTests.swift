import Foundation
import Testing
@testable import AarogyaiOS

@Suite("AppCoordinator")
@MainActor
struct AppCoordinatorTests {
    let userRepo = MockUserRepository()
    let authRepo = MockAuthRepository()
    let tokenStore = MockTokenStore()

    func makeSUT() -> AppCoordinator {
        AppCoordinator(
            getCurrentUser: GetCurrentUserUseCase(userRepository: userRepo),
            logout: LogoutUseCase(authRepository: authRepo, tokenStore: tokenStore)
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
}
