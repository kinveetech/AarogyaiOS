import Foundation
@testable import AarogyaiOS

final class MockNotificationRepository: NotificationRepository, @unchecked Sendable {
    var getPreferencesResult: Result<NotificationPreferences, Error> = .success(.stub)
    var updatePreferencesResult: Result<NotificationPreferences, Error> = .success(.stub)
    var registerDeviceResult: Result<DeviceToken, Error> = .success(
        DeviceToken(id: "dt-1", deviceToken: "token", platform: "ios", deviceName: "iPhone", appVersion: "1.0", registeredAt: .now, updatedAt: .now)
    )
    var unregisterDeviceResult: Result<Void, Error> = .success(())

    var getPreferencesCallCount = 0
    var updatePreferencesCallCount = 0
    var registerDeviceCallCount = 0
    var unregisterDeviceCallCount = 0

    func getPreferences() async throws -> NotificationPreferences {
        getPreferencesCallCount += 1
        return try getPreferencesResult.get()
    }

    func updatePreferences(_ preferences: NotificationPreferences) async throws -> NotificationPreferences {
        updatePreferencesCallCount += 1
        return try updatePreferencesResult.get()
    }

    func registerDevice(token: String) async throws -> DeviceToken {
        registerDeviceCallCount += 1
        return try registerDeviceResult.get()
    }

    func unregisterDevice(token: String) async throws {
        unregisterDeviceCallCount += 1
        try unregisterDeviceResult.get()
    }
}
