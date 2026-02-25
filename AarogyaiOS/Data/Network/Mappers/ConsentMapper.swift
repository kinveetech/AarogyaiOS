import Foundation

enum ConsentMapper {
    static func toDomain(_ dto: ConsentRecordResponse) -> ConsentRecord {
        ConsentRecord(
            purpose: ConsentPurpose(rawValue: dto.purpose) ?? .profileManagement,
            isGranted: dto.isGranted,
            source: dto.source,
            occurredAt: Date(iso8601: dto.occurredAt) ?? .now
        )
    }
}
