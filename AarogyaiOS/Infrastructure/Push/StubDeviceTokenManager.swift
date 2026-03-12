import Foundation
import OSLog

/// A no-op device token manager for use in previews, UI tests, and test defaults.
struct StubDeviceTokenManager: DeviceTokenManaging {
    func registerDeviceToken(_ token: String) async {
        Logger.push.info("StubDeviceTokenManager: registerDeviceToken")
    }

    func reregisterIfNeeded() async {
        Logger.push.info("StubDeviceTokenManager: reregisterIfNeeded")
    }

    func unregisterCurrentDevice() async {
        Logger.push.info("StubDeviceTokenManager: unregisterCurrentDevice")
    }

    func currentToken() -> String? {
        nil
    }
}
