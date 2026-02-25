import SwiftUI

enum AppTab: String, CaseIterable, Sendable {
    case reports
    case access
    case emergency
    case settings
}

struct TabCoordinator: View {
    let container: DependencyContainer
    let onSignOut: () async -> Void

    @State private var selectedTab: AppTab = .reports

    var body: some View {
        TabView(selection: $selectedTab) {
            Tab("Reports", systemImage: "doc.text", value: .reports) {
                NavigationStack {
                    ReportsListView(viewModel: ReportsListViewModel(
                        fetchReportsUseCase: container.fetchReportsUseCase
                    ))
                }
            }

            Tab("Access", systemImage: "person.2", value: .access) {
                NavigationStack {
                    AccessGrantsView(viewModel: AccessGrantsViewModel(
                        fetchGrantsUseCase: container.fetchAccessGrantsUseCase,
                        createGrantUseCase: container.createAccessGrantUseCase,
                        revokeGrantUseCase: container.revokeAccessGrantUseCase
                    ))
                }
            }

            Tab("Emergency", systemImage: "phone.fill", value: .emergency) {
                NavigationStack {
                    EmergencyContactsView(viewModel: EmergencyContactsViewModel(
                        fetchUseCase: container.fetchEmergencyContactsUseCase,
                        manageUseCase: container.manageEmergencyContactUseCase
                    ))
                }
            }

            Tab("Settings", systemImage: "gearshape", value: .settings) {
                NavigationStack {
                    SettingsView(viewModel: SettingsViewModel(
                        getCurrentUserUseCase: container.getCurrentUserUseCase,
                        updateProfileUseCase: container.updateProfileUseCase,
                        manageConsentsUseCase: container.manageConsentsUseCase,
                        manageNotificationsUseCase: container.manageNotificationsUseCase,
                        logoutUseCase: container.logoutUseCase,
                        exportDataUseCase: container.exportDataUseCase,
                        requestAccountDeletionUseCase: container.requestAccountDeletionUseCase,
                        onSignOut: onSignOut
                    ))
                }
            }
        }
        .tabBarMinimizeBehavior(.onScrollDown)
    }
}
