import Foundation

enum UserMapper {
    static func toDomain(_ dto: UserProfileResponse) -> User {
        User(
            id: dto.sub,
            firstName: dto.firstName,
            lastName: dto.lastName,
            email: dto.email,
            phone: dto.phone ?? "",
            address: dto.address,
            bloodGroup: dto.bloodGroup.flatMap { BloodGroup(rawValue: $0) },
            dateOfBirth: dto.dateOfBirth.flatMap { Date(iso8601: $0) },
            gender: dto.gender.flatMap { Gender(rawValue: $0) },
            role: dto.roles.compactMap({ UserRole(rawValue: $0) }).first ?? .patient,
            registrationStatus: RegistrationStatus(rawValue: dto.registrationStatus) ?? .registered,
            isAadhaarVerified: false,
            aadhaarRefToken: nil,
            doctorProfile: nil,
            labTechProfile: nil,
            createdAt: .now,
            updatedAt: .now
        )
    }

    static func toDomain(_ dto: RegisterUserResponse) -> User {
        User(
            id: dto.sub,
            firstName: dto.firstName,
            lastName: dto.lastName,
            email: dto.email,
            phone: dto.phone ?? "",
            address: dto.address,
            bloodGroup: dto.bloodGroup.flatMap { BloodGroup(rawValue: $0) },
            dateOfBirth: dto.dateOfBirth.flatMap { Date(iso8601: $0) },
            gender: dto.gender.flatMap { Gender(rawValue: $0) },
            role: UserRole(rawValue: dto.role) ?? .patient,
            registrationStatus: RegistrationStatus(rawValue: dto.registrationStatus) ?? .registered,
            isAadhaarVerified: false,
            aadhaarRefToken: nil,
            doctorProfile: nil,
            labTechProfile: nil,
            createdAt: .now,
            updatedAt: .now
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
            expiresIn: dto.expiresInSeconds
        )
    }
}
