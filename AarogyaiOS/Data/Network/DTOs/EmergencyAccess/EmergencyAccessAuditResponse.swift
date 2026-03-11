import Foundation

struct EmergencyAccessAuditEventDTO: Decodable, Sendable {
    let auditLogId: String
    let occurredAt: String
    let action: String
    let grantId: String?
    let actorUserId: String?
    let actorRole: String?
    let resourceType: String
    let resourceId: String?
    let data: [String: String]
}

struct EmergencyAccessAuditTrailDTO: Decodable, Sendable {
    let page: Int
    let pageSize: Int
    let totalCount: Int
    let items: [EmergencyAccessAuditEventDTO]
}
