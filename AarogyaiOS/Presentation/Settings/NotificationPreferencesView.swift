import SwiftUI

struct NotificationPreferencesView: View {
    @State var viewModel: NotificationPreferencesViewModel

    var body: some View {
        Group {
            if viewModel.isLoading {
                LoadingView("Loading preferences...")
            } else {
                preferencesList
            }
        }
        .navigationTitle("Notifications")
        .task { await viewModel.loadPreferences() }
        .alert("Error", isPresented: .constant(viewModel.error != nil)) {
            Button("OK") { viewModel.error = nil }
        } message: {
            if let error = viewModel.error {
                Text(error)
            }
        }
    }

    private var preferencesList: some View {
        List {
            channelSection(
                title: "Report Uploaded",
                subtitle: "When a new report is uploaded to your account",
                preferences: $viewModel.reportUploaded
            )

            channelSection(
                title: "Access Granted",
                subtitle: "When someone grants or revokes access to records",
                preferences: $viewModel.accessGranted
            )

            channelSection(
                title: "Emergency Access",
                subtitle: "When emergency access is requested or used",
                preferences: $viewModel.emergencyAccess
            )

            Section {
                Button("Save Preferences") {
                    Task { await viewModel.savePreferences() }
                }
                .disabled(!viewModel.hasChanges || viewModel.isSaving)
                .frame(maxWidth: .infinity, alignment: .center)
            }
        }
    }

    private func channelSection(
        title: String,
        subtitle: String,
        preferences: Binding<ChannelPreferences>
    ) -> some View {
        Section {
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(Typography.headline)
                Text(subtitle)
                    .font(Typography.caption)
                    .foregroundStyle(.secondary)
            }

            Toggle("Push Notifications", isOn: preferences.push)
            Toggle("Email", isOn: preferences.email)
            Toggle("SMS", isOn: preferences.sms)
        }
    }
}
