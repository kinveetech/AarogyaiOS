import Foundation

enum EmergencyAccessAuditMapper {
    static func toDomain(_ dto: EmergencyAccessAuditEventDTO) -> EmergencyAccessAuditEntry {
        EmergencyAccessAuditEntry(
            id: dto.auditLogId,
            occurredAt: Date(iso8601: dto.occurredAt) ?? .now,
            action: dto.action,
            grantId: dto.grantId,
            actorUserId: dto.actorUserId,
            actorRole: dto.actorRole,
            resourceType: dto.resourceType,
            resourceId: dto.resourceId,
            metadata: dto.data
        )
    }
}
