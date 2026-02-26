import SwiftUI
import SwiftData

@main
struct AarogyaApp: App {
    @State private var container = DependencyContainer()

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
                LaunchScreen()
            case .unauthenticated:
                LoginView(viewModel: LoginViewModel(
                    loginUseCase: container.loginUseCase,
                    onLoginSuccess: {
                        await coordinator.handleLogin()
                        coordinator.consumePendingDeepLink()
                    }
                ))
            case .registration:
                RegisterView(viewModel: RegisterViewModel(
                    registerUseCase: container.registerUserUseCase,
                    onRegistrationComplete: {
                        await coordinator.handleRegistrationComplete()
                    }
                ))
            case .pendingApproval:
                PendingApprovalView(
                    checkStatusUseCase: container.checkRegistrationStatusUseCase,
                    onStatusChange: { _ in
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
                    selectedTab: $coordinator.selectedTab,
                    onSignOut: { await coordinator.handleLogout() }
                )
            }
        }
        .environment(coordinator)
        .onOpenURL { url in
            coordinator.handleURL(url)
        }
        .task {
            await coordinator.checkAuthState()
            coordinator.consumePendingDeepLink()
        }
    }
}
