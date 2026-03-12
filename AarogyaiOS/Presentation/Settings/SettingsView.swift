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
                NavigationLink(value: SettingsRoute.registeredDevices) {
                    Label("Registered Devices", systemImage: "laptopcomputer.and.iphone")
                }
                .accessibilityIdentifier(AccessibilityID.Settings.registeredDevicesRow)
            }

            Section {
                Button {
                    viewModel.confirmExportData()
                } label: {
                    HStack {
                        Label("Export My Data", systemImage: "square.and.arrow.up")
                        Spacer()
                        if viewModel.isExporting {
                            ProgressView()
                                .accessibilityIdentifier(AccessibilityID.Settings.exportProgress)
                        }
                    }
                }
                .disabled(viewModel.isExporting)
                .accessibilityIdentifier(AccessibilityID.Settings.exportButton)
            } header: {
                Text("Data")
            } footer: {
                Text("Request a copy of all your personal and health data under DPDPA.")
                    .accessibilityIdentifier(AccessibilityID.Settings.exportFooter)
            }

            Section {
                Button(role: .destructive) {
                    viewModel.beginAccountDeletion()
                } label: {
                    HStack {
                        Label("Delete Account", systemImage: "trash")
                        Spacer()
                        if viewModel.isDeletingAccount {
                            ProgressView()
                                .accessibilityIdentifier(AccessibilityID.Settings.deleteAccountProgress)
                        }
                    }
                }
                .disabled(viewModel.isDeletingAccount)
                .accessibilityIdentifier(AccessibilityID.Settings.deleteAccountButton)
            } header: {
                Text("Danger Zone")
            } footer: {
                Text("Permanently delete your account and all associated data. This cannot be undone.")
                    .accessibilityIdentifier(AccessibilityID.Settings.deleteAccountFooter)
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
            case .registeredDevices:
                RegisteredDevicesView(viewModel: RegisteredDevicesViewModel(
                    manageNotificationsUseCase: viewModel.manageNotificationsUseCase,
                    deviceTokenManager: viewModel.deviceTokenManager
                ))
            }
        }
        .alert("Export My Data", isPresented: $viewModel.showExportConfirmation) {
            Button("Cancel", role: .cancel) {}
            Button("Export") {
                Task { await viewModel.exportData() }
            }
            .accessibilityIdentifier(AccessibilityID.Settings.exportConfirmButton)
        } message: {
            Text(
                """
                We will prepare a copy of your personal and health data. \
                You will receive a notification when your export is ready \
                to download.
                """
            )
        }
        .alert("Export Requested", isPresented: $viewModel.exportSuccess) {
            Button("OK") {
                viewModel.dismissExportSuccess()
            }
            .accessibilityIdentifier(AccessibilityID.Settings.exportSuccessOKButton)
        } message: {
            Text("Your data export has been requested. You will be notified when it is ready.")
        }
        // Step 1: Initial warning alert
        .alert("Delete Account?", isPresented: $viewModel.showDeleteConfirmation) {
            Button("Cancel", role: .cancel) {}
            Button("Continue", role: .destructive) {
                viewModel.proceedToDeleteTypingConfirmation()
            }
            .accessibilityIdentifier(AccessibilityID.Settings.deleteConfirmContinueButton)
        } message: {
            Text(
                """
                This will permanently delete your account, including all \
                medical records, access grants, and personal data. This \
                action cannot be undone.
                """
            )
        }
        // Step 2: Type "DELETE" confirmation sheet
        .sheet(isPresented: $viewModel.showDeleteTypingConfirmation) {
            deleteTypingConfirmationSheet
        }
        .alert("Error", isPresented: .constant(viewModel.error != nil)) {
            Button("OK") { viewModel.error = nil }
        } message: {
            if let error = viewModel.error {
                Text(error)
            }
        }
    }

    // MARK: - Delete Typing Confirmation Sheet

    private var deleteTypingConfirmationSheet: some View {
        NavigationStack {
            VStack(spacing: 24) {
                Image(systemName: "exclamationmark.triangle.fill")
                    .font(.system(size: 48))
                    .foregroundStyle(.red)
                    .accessibilityIdentifier(AccessibilityID.Settings.deleteWarningIcon)

                Text("Confirm Account Deletion")
                    .font(Typography.title2)

                Text(
                    """
                    To confirm, type \
                    \(SettingsViewModel.deletionConfirmationKeyword) \
                    below. This will:
                    """
                )
                .font(Typography.body)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)

                VStack(alignment: .leading, spacing: 8) {
                    Label(
                        "Delete all your medical records",
                        systemImage: "doc.fill"
                    )
                    Label(
                        "Revoke all access grants",
                        systemImage: "person.badge.minus"
                    )
                    Label(
                        "Remove all personal data",
                        systemImage: "person.crop.circle.badge.xmark"
                    )
                    Label(
                        "Sign you out permanently",
                        systemImage: "rectangle.portrait.and.arrow.right"
                    )
                }
                .font(Typography.subheadline)
                .foregroundStyle(.secondary)

                TextField(
                    "Type \(SettingsViewModel.deletionConfirmationKeyword) to confirm",
                    text: $viewModel.deleteConfirmationText
                )
                .textInputAutocapitalization(.characters)
                .autocorrectionDisabled()
                .padding()
                .background(.fill.tertiary)
                .clipShape(RoundedRectangle(cornerRadius: 10))
                .accessibilityIdentifier(AccessibilityID.Settings.deleteConfirmationTextField)

                Button {
                    Task { await viewModel.confirmAccountDeletion() }
                } label: {
                    HStack {
                        if viewModel.isDeletingAccount {
                            ProgressView()
                                .tint(.white)
                        }
                        Text("Delete My Account")
                    }
                    .frame(maxWidth: .infinity)
                }
                .buttonStyle(.borderedProminent)
                .tint(.red)
                .disabled(!viewModel.isDeleteConfirmationValid || viewModel.isDeletingAccount)
                .accessibilityIdentifier(AccessibilityID.Settings.deleteConfirmFinalButton)

                Spacer()
            }
            .padding()
            .navigationTitle("Delete Account")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        viewModel.cancelAccountDeletion()
                    }
                    .accessibilityIdentifier(AccessibilityID.Settings.deleteCancelButton)
                }
            }
        }
        .presentationDetents([.medium, .large])
    }
}

enum SettingsRoute: Hashable {
    case profile
    case aadhaarVerification
    case consents
    case notifications
    case registeredDevices
}
