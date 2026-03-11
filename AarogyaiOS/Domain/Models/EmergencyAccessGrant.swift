import Foundation

struct EmergencyAccessGrant: Sendable {
    let grantId: String
    let emergencyContactId: String
    let startsAt: Date
    let expiresAt: Date
    let purpose: String
}
