import Foundation

protocol NotificationRepository: Sendable {
    func getPreferences() async throws -> NotificationPreferences
    func updatePreferences(_ preferences: NotificationPreferences) async throws -> NotificationPreferences
    func registerDevice(token: String) async throws -> DeviceToken
    func unregisterDevice(token: String) async throws
    func listDevices() async throws -> [DeviceToken]
}
