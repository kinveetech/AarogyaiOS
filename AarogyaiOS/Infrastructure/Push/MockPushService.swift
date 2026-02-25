import Foundation
import OSLog

struct MockPushService: PushNotificationService {
    func requestPermission() async throws -> Bool {
        Logger.ui.info("MockPushService: requestPermission (returning true)")
        return true
    }

    func registerDevice(token: String) async throws {
        Logger.ui.info("MockPushService: registerDevice")
    }

    func unregisterDevice(token: String) async throws {
        Logger.ui.info("MockPushService: unregisterDevice")
    }
}
