import Foundation
import OSLog

@Observable
@MainActor
final class RegisteredDevicesViewModel {
    var devices: [DeviceToken] = []
    var isLoading = false
    var error: String?
    var deviceToDeregister: DeviceToken?
    var showDeregisterConfirmation = false
    var isDeregistering = false

    private let manageNotificationsUseCase: ManageNotificationsUseCase
    private let deviceTokenManager: any DeviceTokenManaging

    init(
        manageNotificationsUseCase: ManageNotificationsUseCase,
        deviceTokenManager: any DeviceTokenManaging
    ) {
        self.manageNotificationsUseCase = manageNotificationsUseCase
        self.deviceTokenManager = deviceTokenManager
    }

    var currentDeviceToken: String? {
        deviceTokenManager.currentToken()
    }

    func isCurrentDevice(_ device: DeviceToken) -> Bool {
        guard let currentToken = currentDeviceToken else { return false }
        return device.deviceToken == currentToken
    }

    func loadDevices() async {
        isLoading = true
        error = nil
        do {
            devices = try await manageNotificationsUseCase.listDevices()
        } catch {
            self.error = mapError(error, fallback: "Failed to load registered devices")
            Logger.data.error("Load devices failed: \(error)")
        }
        isLoading = false
    }

    func confirmDeregister(_ device: DeviceToken) {
        deviceToDeregister = device
        showDeregisterConfirmation = true
    }

    func cancelDeregister() {
        deviceToDeregister = nil
        showDeregisterConfirmation = false
    }

    func deregisterDevice() async {
        guard let device = deviceToDeregister else { return }
        isDeregistering = true
        error = nil
        do {
            try await manageNotificationsUseCase.unregisterDevice(token: device.deviceToken)
            devices.removeAll { $0.id == device.id }
            showDeregisterConfirmation = false
            deviceToDeregister = nil
            Logger.data.info("Device deregistered successfully")
        } catch {
            self.error = mapError(error, fallback: "Failed to deregister device")
            Logger.data.error("Deregister device failed: \(error)")
        }
        isDeregistering = false
    }

    func dismissError() {
        error = nil
    }

    private func mapError(_ error: any Error, fallback: String) -> String {
        guard let apiError = error as? APIError else {
            return fallback
        }
        switch apiError {
        case .unauthorized, .tokenRefreshFailed:
            return "Session expired. Please sign in again."
        case .networkError:
            return "Network error. Check your connection and try again."
        case .serverError:
            return "Server error. Please try again later."
        case .rateLimited:
            return "Too many requests. Please try again later."
        case .notFound:
            return "Device not found. It may have already been removed."
        default:
            return fallback
        }
    }
}
