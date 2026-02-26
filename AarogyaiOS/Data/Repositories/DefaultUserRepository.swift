import Foundation

struct DefaultUserRepository: UserRepository {
    private let apiClient: APIClient

    init(apiClient: APIClient) {
        self.apiClient = apiClient
    }

    func getProfile() async throws -> User {
        let response: UserProfileResponse = try await apiClient.request(.userProfile)
        return UserMapper.toDomain(response)
    }

    func updateProfile(_ user: User) async throws -> User {
        let request = UpdateProfileRequest(
            firstName: user.firstName,
            lastName: user.lastName,
            email: user.email,
            phone: user.phone,
            address: user.address,
            bloodGroup: user.bloodGroup?.rawValue,
            dateOfBirth: user.dateOfBirth?.iso8601String,
            gender: user.gender?.rawValue
        )
        let response: UserProfileResponse = try await apiClient.request(.updateProfile, body: request)
        return UserMapper.toDomain(response)
    }

    func register(request: RegistrationRequest) async throws -> User {
        let dto = RegisterUserRequest(
            firstName: request.firstName,
            lastName: request.lastName,
            email: request.email,
            phone: request.phone,
            dateOfBirth: request.dateOfBirth?.iso8601String,
            gender: request.gender?.rawValue,
            bloodGroup: request.bloodGroup?.rawValue,
            address: request.address,
            role: request.role.rawValue,
            doctorData: request.doctorProfile.map {
                DoctorProfileInputDTO(
                    medicalLicenseNumber: $0.medicalLicenseNumber,
                    specialization: $0.specialization,
                    clinicOrHospitalName: $0.clinicOrHospitalName,
                    clinicAddress: $0.clinicAddress
                )
            },
            labTechnicianData: request.labTechProfile.map {
                LabTechProfileInputDTO(
                    labName: $0.labName,
                    labLicenseNumber: $0.labLicenseNumber,
                    nablAccreditationId: $0.nablAccreditationId
                )
            },
            consents: request.consents.map {
                ConsentInputDTO(purpose: $0.purpose.rawValue, isGranted: $0.isGranted)
            }
        )
        let response: RegisterUserResponse = try await apiClient.request(.registerUser, body: dto)
        return UserMapper.toDomain(response)
    }

    func getRegistrationStatus() async throws -> RegistrationStatus {
        let response: RegistrationStatusResponse = try await apiClient.request(.registrationStatus)
        return RegistrationStatus(rawValue: response.registrationStatus) ?? .registered
    }

    func verifyAadhaar(token: String) async throws -> User {
        struct AadhaarRequest: Encodable { let token: String }
        let response: UserProfileResponse = try await apiClient.request(
            .verifyAadhaar,
            body: AadhaarRequest(token: token)
        )
        return UserMapper.toDomain(response)
    }

    func exportData() async throws {
        try await apiClient.requestNoContent(.exportData)
    }

    func requestDeletion() async throws {
        try await apiClient.requestNoContent(.requestDeletion)
    }
}
