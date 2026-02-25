import Foundation

struct NotificationPreferences: Sendable {
    var reportUploaded: ChannelPreferences
    var accessGranted: ChannelPreferences
    var emergencyAccess: ChannelPreferences
}

struct ChannelPreferences: Sendable {
    var push: Bool
    var email: Bool
    var sms: Bool
}
