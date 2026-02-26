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
    @State private var showLaunchScreen = true
    @State private var showContent = false

    init(container: DependencyContainer) {
        self.container = container
        self._coordinator = State(initialValue: AppCoordinator(container: container))
    }

    var body: some View {
        ZStack {
            // Shared background — always visible behind both layers
            SereneBloomBackground()

            // Content layer — appears after launch screen fades out
            if showContent {
                contentView
            }

            // Launch screen overlay — plays bloom then fades out
            if showLaunchScreen {
                LaunchScreen()
                    .transition(.opacity)
            }
        }
        .animation(.easeOut(duration: 0.7), value: showLaunchScreen)
        .environment(coordinator)
        .onOpenURL { url in
            coordinator.handleURL(url)
        }
        .task {
            // Run auth check and minimum 2s display in parallel
            async let auth: Void = coordinator.checkAuthState()
            async let delay: Void = Task.sleep(for: .seconds(2))
            _ = await (try? auth, try? delay)

            // Fade out launch screen
            showLaunchScreen = false

            // Wait for fade to nearly complete, then reveal content
            try? await Task.sleep(for: .milliseconds(500))
            showContent = true
            coordinator.consumePendingDeepLink()
        }
    }

    @ViewBuilder
    private var contentView: some View {
        switch coordinator.state {
        case .loading, .unauthenticated:
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
}
