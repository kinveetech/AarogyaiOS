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
                PlaceholderAuthView {
                    Task { await coordinator.handleLogin() }
                }
            case .pendingApproval:
                PlaceholderStatusView(message: "Your registration is pending approval.")
            case .rejected:
                PlaceholderStatusView(message: "Your registration was not approved.")
            case .authenticated:
                TabCoordinator()
            }
        }
        .environment(coordinator)
        .task {
            await coordinator.checkAuthState()
        }
    }
}

// MARK: - Placeholder Views (replaced by real views in later issues)

private struct PlaceholderAuthView: View {
    let onLogin: () -> Void

    var body: some View {
        VStack(spacing: 20) {
            Text("Aarogya")
                .font(Typography.largeTitle)
            Text("Sign in to continue")
                .font(Typography.body)
                .foregroundStyle(.secondary)
            Button("Sign In") { onLogin() }
                .buttonStyle(.borderedProminent)
                .tint(Color.Fallback.brandPrimary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .sereneBloomBackground()
    }
}

private struct PlaceholderStatusView: View {
    let message: String

    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "clock.fill")
                .font(.system(size: 48))
                .foregroundStyle(Color.Fallback.brandAccent)
            Text(message)
                .font(Typography.body)
                .multilineTextAlignment(.center)
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .sereneBloomBackground()
    }
}
