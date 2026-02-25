import Foundation

struct NotificationPreferencesResponse: Decodable, Sendable {
    let reportUploaded: ChannelPreferencesDTO
    let accessGranted: ChannelPreferencesDTO
    let emergencyAccess: ChannelPreferencesDTO
}

struct ChannelPreferencesDTO: Codable, Sendable {
    let push: Bool
    let email: Bool
    let sms: Bool
}

struct UpdateNotificationPreferencesRequest: Encodable, Sendable {
    let reportUploaded: ChannelPreferencesDTO
    let accessGranted: ChannelPreferencesDTO
    let emergencyAccess: ChannelPreferencesDTO
}

struct DeviceTokenRequestDTO: Encodable, Sendable {
    let deviceToken: String
    let platform: String
    let deviceName: String
    let appVersion: String
}

struct DeviceTokenResponse: Decodable, Sendable {
    let id: String
    let deviceToken: String
    let platform: String
    let deviceName: String
    let appVersion: String
    let registeredAt: String
    let updatedAt: String
}
