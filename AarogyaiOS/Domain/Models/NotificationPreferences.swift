import Foundation

struct NotificationPreferences: Sendable, Equatable {
    var reportUploaded: ChannelPreferences
    var accessGranted: ChannelPreferences
    var emergencyAccess: ChannelPreferences
}

struct ChannelPreferences: Sendable, Equatable {
    var push: Bool
    var email: Bool
    var sms: Bool
}
