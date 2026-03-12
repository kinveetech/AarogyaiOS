import Foundation

struct AccessGrant: Identifiable, Sendable {
    let id: String
    var patientId: String
    var grantedToUserId: String
    var grantedToUserName: String?
    var grantedByUserId: String
    var grantedByUserName: String?
    var grantReason: String?
    var scope: AccessScope
    var status: AccessGrantStatus
    var startsAt: Date
    var expiresAt: Date?
    var revokedAt: Date?
    var createdAt: Date
}

struct AccessScope: Sendable {
    var allReports: Bool
    var reportIds: [String]
}
