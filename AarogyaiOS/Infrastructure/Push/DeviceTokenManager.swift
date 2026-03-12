import Foundation
import OSLog

/// Coordinates device token lifecycle: registration on push permission grant,
/// re-registration on app launch when the token changes, and unregistration on sign-out.
protocol DeviceTokenManaging: Sendable {
    /// Registers a device token with the backend. Stores the token locally
    /// and skips the API call if the token has not changed since last registration.
    func registerDeviceToken(_ token: String) async

    /// Re-registers the stored device token on app launch. Always sends the
    /// current token to the backend so the server can update metadata.
    func reregisterIfNeeded() async

    /// Unregisters the current device token from the backend and clears local storage.
    func unregisterCurrentDevice() async

    /// Returns the currently stored device token, if any.
    func currentToken() -> String?
}

/// Abstracts local storage of the device push token for testability.
protocol DeviceTokenStoring: Sendable {
    func saveToken(_ token: String) throws
    func readToken() -> String?
    func deleteToken() throws
}

/// Stores device push tokens in the Keychain.
struct KeychainDeviceTokenStore: DeviceTokenStoring {
    private let keychainService: KeychainService
    private let key = Constants.Keychain.deviceTokenKey

    init(keychainService: KeychainService) {
        self.keychainService = keychainService
    }

    func saveToken(_ token: String) throws {
        try keychainService.save(token, for: key)
    }

    func readToken() -> String? {
        try? keychainService.readString(key: key)
    }

    func deleteToken() throws {
        try keychainService.delete(key: key)
    }
}

final class DeviceTokenManager: DeviceTokenManaging, @unchecked Sendable {
    private let notificationRepository: any NotificationRepository
    private let tokenStore: any DeviceTokenStoring

    init(
        notificationRepository: any NotificationRepository,
        tokenStore: any DeviceTokenStoring
    ) {
        self.notificationRepository = notificationRepository
        self.tokenStore = tokenStore
    }

    func registerDeviceToken(_ token: String) async {
        let storedToken = currentToken()

        // Skip registration if token has not changed
        if storedToken == token {
            Logger.push.info("Device token unchanged, skipping registration")
            return
        }

        do {
            _ = try await notificationRepository.registerDevice(token: token)
            try tokenStore.saveToken(token)
            Logger.push.info("Device token registered successfully")
        } catch {
            Logger.push.error("Device token registration failed: \(error)")
        }
    }

    func reregisterIfNeeded() async {
        guard let storedToken = currentToken() else {
            Logger.push.info("No stored device token, skipping re-registration")
            return
        }

        do {
            _ = try await notificationRepository.registerDevice(token: storedToken)
            Logger.push.info("Device token re-registered on launch")
        } catch {
            Logger.push.error("Device token re-registration failed: \(error)")
        }
    }

    func unregisterCurrentDevice() async {
        guard let storedToken = currentToken() else {
            Logger.push.info("No stored device token, skipping unregistration")
            return
        }

        do {
            try await notificationRepository.unregisterDevice(token: storedToken)
            try tokenStore.deleteToken()
            Logger.push.info("Device token unregistered successfully")
        } catch {
            Logger.push.error("Device token unregistration failed: \(error)")
            // Still attempt to clear local token even if server call fails
            try? tokenStore.deleteToken()
        }
    }

    func currentToken() -> String? {
        tokenStore.readToken()
    }
}
