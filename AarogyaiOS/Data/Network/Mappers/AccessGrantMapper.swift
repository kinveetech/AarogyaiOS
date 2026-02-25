import Foundation

enum AccessGrantMapper {
    static func toDomain(_ dto: AccessGrantResponse) -> AccessGrant {
        AccessGrant(
            id: dto.id,
            patientId: dto.patientId,
            grantedToUserId: dto.grantedToUserId,
            grantedToUserName: dto.grantedToUserName,
            grantedByUserId: dto.grantedByUserId,
            grantReason: dto.grantReason,
            scope: AccessScope(
                allReports: dto.allReports,
                reportIds: dto.reportIds ?? []
            ),
            status: AccessGrantStatus(rawValue: dto.status) ?? .active,
            startsAt: Date(iso8601: dto.startsAt) ?? .now,
            expiresAt: dto.expiresAt.flatMap { Date(iso8601: $0) },
            revokedAt: dto.revokedAt.flatMap { Date(iso8601: $0) },
            createdAt: Date(iso8601: dto.createdAt) ?? .now
        )
    }
}
