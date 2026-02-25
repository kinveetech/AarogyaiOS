import SwiftUI

struct SettingsView: View {
    @State var viewModel: SettingsViewModel

    var body: some View {
        List {
            Section("Account") {
                NavigationLink(value: SettingsRoute.profile) {
                    Label("Profile", systemImage: "person")
                }
                NavigationLink(value: SettingsRoute.consents) {
                    Label("Privacy & Consents", systemImage: "hand.raised")
                }
                NavigationLink(value: SettingsRoute.notifications) {
                    Label("Notifications", systemImage: "bell")
                }
            }

            Section("Data") {
                Button {
                    Task { await viewModel.exportData() }
                } label: {
                    Label("Export My Data", systemImage: "square.and.arrow.up")
                }
                .disabled(viewModel.isExporting)
            }

            Section("Danger Zone") {
                Button(role: .destructive) {
                    viewModel.showDeleteConfirmation = true
                } label: {
                    Label("Delete Account", systemImage: "trash")
                }
            }

            Section {
                Button("Sign Out", role: .destructive) {
                    Task { await viewModel.signOut() }
                }
            }

            Section {
                HStack {
                    Spacer()
                    Text("Aarogya v1.0")
                        .font(Typography.caption)
                        .foregroundStyle(.tertiary)
                    Spacer()
                }
            }
        }
        .navigationTitle("Settings")
        .navigationDestination(for: SettingsRoute.self) { route in
            switch route {
            case .profile:
                ProfileEditView(viewModel: ProfileEditViewModel(
                    getCurrentUserUseCase: viewModel.getCurrentUserUseCase,
                    updateProfileUseCase: viewModel.updateProfileUseCase
                ))
            case .consents:
                ConsentsView(viewModel: ConsentsViewModel(
                    manageConsentsUseCase: viewModel.manageConsentsUseCase
                ))
            case .notifications:
                NotificationPreferencesView(viewModel: NotificationPreferencesViewModel(
                    manageNotificationsUseCase: viewModel.manageNotificationsUseCase
                ))
            }
        }
        .alert("Delete Account", isPresented: $viewModel.showDeleteConfirmation) {
            Button("Cancel", role: .cancel) {}
            Button("Delete", role: .destructive) {
                Task { await viewModel.requestAccountDeletion() }
            }
        } message: {
            Text("This action is irreversible. All your data will be permanently deleted.")
        }
        .alert("Error", isPresented: .constant(viewModel.error != nil)) {
            Button("OK") { viewModel.error = nil }
        } message: {
            if let error = viewModel.error {
                Text(error)
            }
        }
    }
}

enum SettingsRoute: Hashable {
    case profile
    case consents
    case notifications
}
