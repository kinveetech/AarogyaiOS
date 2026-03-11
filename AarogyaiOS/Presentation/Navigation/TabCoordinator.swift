import SwiftUI

enum AppTab: String, CaseIterable, Sendable {
    case reports
    case access
    case emergency
    case settings
}

struct TabCoordinator: View {
    let container: DependencyContainer
    @Binding var selectedTab: AppTab
    let onSignOut: () async -> Void

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
                    EmergencyContactsView(
                        viewModel: EmergencyContactsViewModel(
                            fetchUseCase: container.fetchEmergencyContactsUseCase,
                            manageUseCase: container.manageEmergencyContactUseCase
                        ),
                        fetchAuditUseCase: container.fetchEmergencyAccessAuditUseCase
                    )
                    .navigationDestination(for: Route.self) { route in
                        if case .emergencyAccessAudit = route {
                            EmergencyAccessAuditView(
                                viewModel: EmergencyAccessAuditViewModel(
                                    fetchAuditUseCase: container.fetchEmergencyAccessAuditUseCase
                                )
                            )
                        }
                    }
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
