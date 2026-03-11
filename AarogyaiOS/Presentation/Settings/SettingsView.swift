import SwiftUI

struct SettingsView: View {
    @State var viewModel: SettingsViewModel

    var body: some View {
        List {
            Section("Account") {
                NavigationLink(value: SettingsRoute.profile) {
                    Label("Profile", systemImage: "person")
                }
                .accessibilityIdentifier(AccessibilityID.Settings.profileRow)
                NavigationLink(value: SettingsRoute.aadhaarVerification) {
                    Label("Aadhaar Verification", systemImage: "person.badge.shield.checkmark")
                }
                .accessibilityIdentifier(AccessibilityID.Settings.aadhaarVerificationRow)
                NavigationLink(value: SettingsRoute.consents) {
                    Label("Privacy & Consents", systemImage: "hand.raised")
                }
                .accessibilityIdentifier(AccessibilityID.Settings.consentsRow)
                NavigationLink(value: SettingsRoute.notifications) {
                    Label("Notifications", systemImage: "bell")
                }
                .accessibilityIdentifier(AccessibilityID.Settings.notificationsRow)
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
                .accessibilityIdentifier(AccessibilityID.Settings.deleteAccountButton)
            }

            Section {
                Button("Sign Out", role: .destructive) {
                    Task { await viewModel.signOut() }
                }
                .accessibilityIdentifier(AccessibilityID.Settings.signOutButton)
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
            case .aadhaarVerification:
                AadhaarVerificationView(viewModel: AadhaarVerificationViewModel(
                    verifyAadhaarUseCase: viewModel.verifyAadhaarUseCase,
                    getCurrentUserUseCase: viewModel.getCurrentUserUseCase
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
    case aadhaarVerification
    case consents
    case notifications
}
