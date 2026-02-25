import Foundation

enum UserMapper {
    static func toDomain(_ dto: UserProfileResponse) -> User {
        User(
            id: dto.id,
            firstName: dto.firstName,
            lastName: dto.lastName,
            email: dto.email,
            phone: dto.phone,
            address: dto.address,
            bloodGroup: dto.bloodGroup.flatMap { BloodGroup(rawValue: $0) },
            dateOfBirth: dto.dateOfBirth.flatMap { Date(iso8601: $0) },
            gender: dto.gender.flatMap { Gender(rawValue: $0) },
            role: UserRole(rawValue: dto.role) ?? .patient,
            registrationStatus: RegistrationStatus(rawValue: dto.registrationStatus) ?? .registered,
            isAadhaarVerified: dto.isAadhaarVerified,
            aadhaarRefToken: dto.aadhaarRefToken,
            doctorProfile: dto.doctorProfile.map { toDomain($0) },
            labTechProfile: dto.labTechnicianProfile.map { toDomain($0) },
            createdAt: Date(iso8601: dto.createdAt) ?? .now,
            updatedAt: Date(iso8601: dto.updatedAt) ?? .now
        )
    }

    static func toDomain(_ dto: DoctorProfileDTO) -> DoctorProfile {
        DoctorProfile(
            id: dto.id,
            medicalLicenseNumber: dto.medicalLicenseNumber,
            specialization: dto.specialization,
            clinicOrHospitalName: dto.clinicOrHospitalName,
            clinicAddress: dto.clinicAddress
        )
    }

    static func toDomain(_ dto: LabTechProfileDTO) -> LabTechnicianProfile {
        LabTechnicianProfile(
            id: dto.id,
            labName: dto.labName,
            labLicenseNumber: dto.labLicenseNumber,
            nablAccreditationId: dto.nablAccreditationId
        )
    }

    static func toTokens(_ dto: TokenResponse) -> AuthTokens {
        AuthTokens(
            accessToken: dto.accessToken,
            refreshToken: dto.refreshToken,
            idToken: dto.idToken,
            expiresIn: dto.expiresIn
        )
    }
}
