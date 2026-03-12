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
    let userRole: UserRole
    let onSignOut: () async -> Void

    @State private var reportsListViewModel: ReportsListViewModel?

    var body: some View {
        TabView(selection: $selectedTab) {
            Tab("Reports", systemImage: "doc.text", value: .reports) {
                NavigationStack {
                    ReportsListView(viewModel: resolveReportsListViewModel())
                    .navigationDestination(for: Route.self) { route in
                        if case .reportDetail(let id) = route {
                            ReportDetailView(viewModel: ReportDetailViewModel(
                                reportId: id,
                                fetchReportsUseCase: container.fetchReportsUseCase,
                                downloadReportUseCase: container.downloadReportUseCase,
                                deleteReportUseCase: container.deleteReportUseCase,
                                extractionUseCase: container.extractionUseCase,
                                onDelete: { [reportsListViewModel] in
                                    reportsListViewModel?.markNeedsRefresh()
                                }
                            ))
                        }
                    }
                }
            }

            Tab("Access", systemImage: "person.2", value: .access) {
                NavigationStack {
                    AccessGrantsView(viewModel: AccessGrantsViewModel(
                        fetchGrantsUseCase: container.fetchAccessGrantsUseCase,
                        createGrantUseCase: container.createAccessGrantUseCase,
                        revokeGrantUseCase: container.revokeAccessGrantUseCase,
                        userRole: userRole
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
                        verifyAadhaarUseCase: container.verifyAadhaarUseCase,
                        manageConsentsUseCase: container.manageConsentsUseCase,
                        manageNotificationsUseCase: container.manageNotificationsUseCase,
                        deviceTokenManager: container.deviceTokenManager,
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

    private func resolveReportsListViewModel() -> ReportsListViewModel {
        if let existing = reportsListViewModel {
            return existing
        }
        let viewModel = ReportsListViewModel(
            fetchReportsUseCase: container.fetchReportsUseCase
        )
        reportsListViewModel = viewModel
        return viewModel
    }
}
