import Foundation

protocol PushNotificationService: Sendable {
    func requestPermission() async throws -> Bool
    func registerDevice(token: String) async throws
    func unregisterDevice(token: String) async throws
}
