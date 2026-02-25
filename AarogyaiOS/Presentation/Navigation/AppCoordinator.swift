import SwiftUI
import OSLog

@Observable
@MainActor
final class AppCoordinator {
    enum AppState: Sendable {
        case loading
        case unauthenticated
        case pendingApproval
        case rejected
        case authenticated(User)
    }

    var state: AppState = .loading
    var pendingDeepLink: DeepLink?
    var selectedTab: AppTab = .reports

    private let container: DependencyContainer

    init(container: DependencyContainer) {
        self.container = container
    }

    func checkAuthState() async {
        do {
            let user = try await container.getCurrentUserUseCase.execute()
            switch user.registrationStatus {
            case .registered, .pendingApproval:
                state = .pendingApproval
            case .rejected:
                state = .rejected
            case .approved:
                state = .authenticated(user)
            }
        } catch let error as APIError {
            switch error {
            case .unauthorized, .tokenRefreshFailed:
                state = .unauthenticated
            case .registrationRequired:
                state = .unauthenticated
            case .registrationPending:
                state = .pendingApproval
            case .registrationRejected:
                state = .rejected
            default:
                Logger.auth.error("Auth check failed: \(error)")
                state = .unauthenticated
            }
        } catch {
            Logger.auth.error("Auth check failed: \(error)")
            state = .unauthenticated
        }
    }

    func handleLogin() async {
        await checkAuthState()
    }

    func handleLogout() async {
        do {
            try await container.logoutUseCase.execute()
        } catch {
            Logger.auth.error("Logout error: \(error)")
        }
        state = .unauthenticated
    }

    func handleRegistrationComplete() async {
        await checkAuthState()
    }

    func handleDeepLink(_ deepLink: DeepLink) {
        switch state {
        case .authenticated:
            applyDeepLink(deepLink)
        default:
            pendingDeepLink = deepLink
        }
    }

    func handleURL(_ url: URL) {
        guard let deepLink = DeepLinkHandler.parse(url: url) else { return }
        handleDeepLink(deepLink)
    }

    func consumePendingDeepLink() {
        guard let deepLink = pendingDeepLink else { return }
        pendingDeepLink = nil
        applyDeepLink(deepLink)
    }

    private func applyDeepLink(_ deepLink: DeepLink) {
        switch deepLink {
        case .reports:
            selectedTab = .reports
        case .reportDetail:
            selectedTab = .reports
        case .accessGrants:
            selectedTab = .access
        case .emergency:
            selectedTab = .emergency
        case .settings:
            selectedTab = .settings
        }
    }
}
