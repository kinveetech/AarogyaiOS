import Foundation

struct EmergencyAccessAuditEntry: Identifiable, Sendable {
    let id: String
    let occurredAt: Date
    let action: String
    let grantId: String?
    let actorUserId: String?
    let actorRole: String?
    let resourceType: String
    let resourceId: String?
    let metadata: [String: String]
}
