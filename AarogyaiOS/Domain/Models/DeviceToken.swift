import Foundation

struct DeviceToken: Identifiable, Sendable {
    let id: String
    var deviceToken: String
    var platform: String
    var deviceName: String
    var appVersion: String
    var registeredAt: Date
    var updatedAt: Date
}
