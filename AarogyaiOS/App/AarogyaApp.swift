import SwiftUI
import SwiftData

@main
struct AarogyaApp: App {
    @State private var container = DependencyContainer()
    @State private var coordinator: AppCoordinator?

    var body: some Scene {
        WindowGroup {
            RootView(container: container)
                .modelContainer(container.modelContainer)
        }
    }
}

struct RootView: View {
    let container: DependencyContainer
    @State private var coordinator: AppCoordinator

    init(container: DependencyContainer) {
        self.container = container
        self._coordinator = State(initialValue: AppCoordinator(container: container))
    }

    var body: some View {
        Group {
            switch coordinator.state {
            case .loading:
                ProgressView("Loading…")
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .sereneBloomBackground()
            case .unauthenticated:
                LoginView(viewModel: LoginViewModel(
                    loginUseCase: container.loginUseCase,
                    onLoginSuccess: { await coordinator.handleLogin() }
                ))
            case .pendingApproval:
                PendingApprovalView(
                    checkStatusUseCase: container.checkRegistrationStatusUseCase,
                    onStatusChange: { status in
                        Task { await coordinator.handleRegistrationComplete() }
                    },
                    onSignOut: {
                        Task { await coordinator.handleLogout() }
                    }
                )
            case .rejected:
                RejectedRegistrationView(
                    reason: nil,
                    onSignOut: {
                        Task { await coordinator.handleLogout() }
                    }
                )
            case .authenticated:
                TabCoordinator(
                    container: container,
                    onSignOut: { await coordinator.handleLogout() }
                )
            }
        }
        .environment(coordinator)
        .task {
            await coordinator.checkAuthState()
        }
    }
}
