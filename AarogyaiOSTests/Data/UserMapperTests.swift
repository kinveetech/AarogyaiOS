import Testing
import Foundation
@testable import AarogyaiOS

@Suite("UserMapper")
struct UserMapperTests {

    // MARK: - UserProfileResponse mapping

    @Test func toDomainMapsUserProfileResponse() {
        let dto = UserProfileResponse(
            sub: "user-123",
            firstName: "Test",
            lastName: "User",
            email: "test@example.com",
            phone: "+911234567890",
            address: "123 Main St",
            bloodGroup: "O+",
            dateOfBirth: "2000-01-15",
            gender: "male",
            roles: ["patient"],
            registrationStatus: "approved"
        )

        let user = UserMapper.toDomain(dto)

        #expect(user.id == "user-123")
        #expect(user.firstName == "Test")
        #expect(user.lastName == "User")
        #expect(user.email == "test@example.com")
        #expect(user.phone == "+911234567890")
        #expect(user.address == "123 Main St")
        #expect(user.bloodGroup == .oPositive)
        #expect(user.gender == .male)
        #expect(user.role == .patient)
        #expect(user.registrationStatus == .approved)
    }

    @Test func toDomainMapsNilPhoneToEmptyString() {
        let dto = UserProfileResponse(
            sub: "user-123",
            firstName: "Test",
            lastName: "User",
            email: "test@example.com",
            phone: nil,
            address: nil,
            bloodGroup: nil,
            dateOfBirth: nil,
            gender: nil,
            roles: ["patient"],
            registrationStatus: "approved"
        )

        let user = UserMapper.toDomain(dto)
        #expect(user.phone == "")
    }

    @Test func toDomainMapsFirstRoleFromRolesArray() {
        let dto = UserProfileResponse(
            sub: "user-123",
            firstName: "Test",
            lastName: "Doctor",
            email: "doc@example.com",
            phone: nil,
            address: nil,
            bloodGroup: nil,
            dateOfBirth: nil,
            gender: nil,
            roles: ["doctor", "patient"],
            registrationStatus: "approved"
        )

        let user = UserMapper.toDomain(dto)
        #expect(user.role == .doctor)
    }

    @Test func toDomainDefaultsToPatientForUnknownRole() {
        let dto = UserProfileResponse(
            sub: "user-123",
            firstName: "Test",
            lastName: "User",
            email: "test@example.com",
            phone: nil,
            address: nil,
            bloodGroup: nil,
            dateOfBirth: nil,
            gender: nil,
            roles: ["unknown_role"],
            registrationStatus: "approved"
        )

        let user = UserMapper.toDomain(dto)
        #expect(user.role == .patient)
    }

    @Test func toDomainDefaultsToPatientForEmptyRolesArray() {
        let dto = UserProfileResponse(
            sub: "user-123",
            firstName: "Test",
            lastName: "User",
            email: "test@example.com",
            phone: nil,
            address: nil,
            bloodGroup: nil,
            dateOfBirth: nil,
            gender: nil,
            roles: [],
            registrationStatus: "approved"
        )

        let user = UserMapper.toDomain(dto)
        #expect(user.role == .patient)
    }

    @Test func toDomainMapsNilOptionalFields() {
        let dto = UserProfileResponse(
            sub: "user-123",
            firstName: "Test",
            lastName: "User",
            email: "test@example.com",
            phone: nil,
            address: nil,
            bloodGroup: nil,
            dateOfBirth: nil,
            gender: nil,
            roles: ["patient"],
            registrationStatus: "approved"
        )

        let user = UserMapper.toDomain(dto)
        #expect(user.address == nil)
        #expect(user.bloodGroup == nil)
        #expect(user.dateOfBirth == nil)
        #expect(user.gender == nil)
    }

    // MARK: - RegisterUserResponse mapping

    @Test func toDomainMapsRegisterUserResponse() {
        let dto = RegisterUserResponse(
            sub: "new-user-456",
            role: "patient",
            registrationStatus: "pending_approval",
            email: "new@example.com",
            firstName: "New",
            lastName: "User",
            phone: "+919876543210",
            address: nil,
            bloodGroup: "A+",
            dateOfBirth: nil,
            gender: "female",
            consentsGranted: ["profile_management"]
        )

        let user = UserMapper.toDomain(dto)

        #expect(user.id == "new-user-456")
        #expect(user.firstName == "New")
        #expect(user.lastName == "User")
        #expect(user.email == "new@example.com")
        #expect(user.phone == "+919876543210")
        #expect(user.role == .patient)
        #expect(user.registrationStatus == .pendingApproval)
        #expect(user.bloodGroup == .aPositive)
        #expect(user.gender == .female)
    }

    @Test func toDomainMapsRegisterUserResponseWithNilPhone() {
        let dto = RegisterUserResponse(
            sub: "user-789",
            role: "doctor",
            registrationStatus: "pending_approval",
            email: "doc@example.com",
            firstName: "Doc",
            lastName: "User",
            phone: nil,
            address: nil,
            bloodGroup: nil,
            dateOfBirth: nil,
            gender: nil,
            consentsGranted: nil
        )

        let user = UserMapper.toDomain(dto)
        #expect(user.phone == "")
        #expect(user.role == .doctor)
    }

    // MARK: - TokenResponse mapping

    @Test func toTokensMapsTokenResponse() {
        let dto = TokenResponse(
            accessToken: "access-123",
            refreshToken: "refresh-456",
            idToken: "id-789",
            expiresInSeconds: 3600,
            tokenType: "Bearer",
            isLinkedAccount: false
        )

        let tokens = UserMapper.toTokens(dto)

        #expect(tokens.accessToken == "access-123")
        #expect(tokens.refreshToken == "refresh-456")
        #expect(tokens.idToken == "id-789")
        #expect(tokens.expiresIn == 3600)
    }

    @Test func toTokensWithNilLinkedAccount() {
        let dto = TokenResponse(
            accessToken: "a",
            refreshToken: "r",
            idToken: "i",
            expiresInSeconds: 7200,
            tokenType: "Bearer",
            isLinkedAccount: nil
        )

        let tokens = UserMapper.toTokens(dto)
        #expect(tokens.expiresIn == 7200)
    }

    // MARK: - DoctorProfile mapping

    @Test func toDomainMapsDoctorProfile() {
        let dto = DoctorProfileDTO(
            id: "doc-1",
            medicalLicenseNumber: "ML-001",
            specialization: "Cardiology",
            clinicOrHospitalName: "Heart Center",
            clinicAddress: "456 Medical Ave"
        )

        let profile = UserMapper.toDomain(dto)

        #expect(profile.id == "doc-1")
        #expect(profile.medicalLicenseNumber == "ML-001")
        #expect(profile.specialization == "Cardiology")
        #expect(profile.clinicOrHospitalName == "Heart Center")
        #expect(profile.clinicAddress == "456 Medical Ave")
    }

    // MARK: - LabTechProfile mapping

    @Test func toDomainMapsLabTechProfile() {
        let dto = LabTechProfileDTO(
            id: "lab-1",
            labName: "Test Lab",
            labLicenseNumber: "LL-001",
            nablAccreditationId: "NABL-123"
        )

        let profile = UserMapper.toDomain(dto)

        #expect(profile.id == "lab-1")
        #expect(profile.labName == "Test Lab")
        #expect(profile.labLicenseNumber == "LL-001")
        #expect(profile.nablAccreditationId == "NABL-123")
    }
}
