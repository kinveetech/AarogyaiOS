import Foundation

enum EmergencyAccessMapper {
    static func toDomain(_ dto: EmergencyAccessResponseDTO) -> EmergencyAccessGrant {
        EmergencyAccessGrant(
            grantId: dto.grantId,
            emergencyContactId: dto.emergencyContactId,
            startsAt: Date(iso8601: dto.startsAt) ?? .now,
            expiresAt: Date(iso8601: dto.expiresAt) ?? .now,
            purpose: dto.purpose
        )
    }

    static func toDTO(_ input: EmergencyAccessInput) -> EmergencyAccessRequestDTO {
        EmergencyAccessRequestDTO(
            patientSub: input.patientSub,
            emergencyContactPhone: input.emergencyContactPhone,
            doctorSub: input.doctorSub,
            reason: input.reason,
            durationHours: input.durationHours
        )
    }
}
