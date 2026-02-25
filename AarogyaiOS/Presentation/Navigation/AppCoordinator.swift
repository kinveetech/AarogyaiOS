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
}
