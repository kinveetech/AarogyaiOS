import SwiftUI

struct RegisteredDevicesView: View {
    @State var viewModel: RegisteredDevicesViewModel

    var body: some View {
        Group {
            if viewModel.isLoading {
                LoadingView("Loading devices...")
                    .accessibilityIdentifier(AccessibilityID.RegisteredDevices.loadingView)
            } else if viewModel.devices.isEmpty {
                emptyState
            } else {
                devicesList
            }
        }
        .navigationTitle("Registered Devices")
        .task { await viewModel.loadDevices() }
        .alert("Error", isPresented: .constant(viewModel.error != nil)) {
            Button("OK") { viewModel.dismissError() }
        } message: {
            if let error = viewModel.error {
                Text(error)
            }
        }
        .alert(
            "Deregister Device?",
            isPresented: $viewModel.showDeregisterConfirmation
        ) {
            Button("Cancel", role: .cancel) {
                viewModel.cancelDeregister()
            }
            Button("Deregister", role: .destructive) {
                Task { await viewModel.deregisterDevice() }
            }
            .accessibilityIdentifier(AccessibilityID.RegisteredDevices.deregisterConfirmButton)
        } message: {
            if let device = viewModel.deviceToDeregister {
                Text(
                    """
                    This will stop push notifications on \
                    \(device.deviceName). You can re-register by \
                    signing in again on that device.
                    """
                )
            }
        }
    }

    // MARK: - Empty State

    private var emptyState: some View {
        ContentUnavailableView(
            "No Registered Devices",
            systemImage: "laptopcomputer.and.iphone",
            description: Text("No devices are registered for push notifications.")
        )
        .accessibilityIdentifier(AccessibilityID.RegisteredDevices.emptyState)
    }

    // MARK: - Devices List

    private var devicesList: some View {
        List {
            Section {
                ForEach(viewModel.devices) { device in
                    deviceRow(device)
                        .accessibilityIdentifier(
                            AccessibilityID.RegisteredDevices.deviceRow(device.id)
                        )
                        .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                            Button(role: .destructive) {
                                viewModel.confirmDeregister(device)
                            } label: {
                                Label("Deregister", systemImage: "trash")
                            }
                            .accessibilityIdentifier(
                                AccessibilityID.RegisteredDevices.deregisterButton(device.id)
                            )
                        }
                }
            } header: {
                Text("Devices")
            } footer: {
                Text("Swipe left on a device to deregister it from receiving push notifications.")
            }
        }
        .accessibilityIdentifier(AccessibilityID.RegisteredDevices.list)
    }

    // MARK: - Device Row

    private func deviceRow(_ device: DeviceToken) -> some View {
        HStack(spacing: 12) {
            Image(systemName: platformIcon(device.platform))
                .font(.title2)
                .foregroundStyle(.tint)
                .frame(width: 32)

            VStack(alignment: .leading, spacing: 4) {
                HStack(spacing: 6) {
                    Text(device.deviceName)
                        .font(Typography.headline)

                    if viewModel.isCurrentDevice(device) {
                        Text("This Device")
                            .font(Typography.caption)
                            .foregroundStyle(.white)
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2)
                            .background(.tint, in: Capsule())
                            .accessibilityIdentifier(
                                AccessibilityID.RegisteredDevices.currentBadge(device.id)
                            )
                    }
                }

                HStack(spacing: 8) {
                    Label(device.platform.capitalized, systemImage: "cpu")
                    Label("v\(device.appVersion)", systemImage: "app.badge")
                }
                .font(Typography.caption)
                .foregroundStyle(.secondary)

                Text("Registered \(device.registeredAt.formatted(date: .abbreviated, time: .shortened))")
                    .font(Typography.caption)
                    .foregroundStyle(.tertiary)
            }

            Spacer()
        }
        .padding(.vertical, 4)
    }

    // MARK: - Helpers

    private func platformIcon(_ platform: String) -> String {
        switch platform.lowercased() {
        case "ios": "iphone"
        case "android": "phone"
        case "web": "globe"
        default: "desktopcomputer"
        }
    }
}
