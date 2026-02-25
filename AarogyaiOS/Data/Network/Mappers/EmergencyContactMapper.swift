import Foundation

enum EmergencyContactMapper {
    static func toDomain(_ dto: EmergencyContactResponse) -> EmergencyContact {
        EmergencyContact(
            id: dto.id,
            name: dto.name,
            phone: dto.phone,
            relationship: Relationship(rawValue: dto.relationship) ?? .other,
            isPrimary: dto.isPrimary,
            createdAt: Date(iso8601: dto.createdAt) ?? .now,
            updatedAt: Date(iso8601: dto.updatedAt) ?? .now
        )
    }
}
