import Foundation

protocol UserRepository: Sendable {
    func getProfile() async throws -> User
    func updateProfile(_ user: User) async throws -> User
    func register(request: RegistrationRequest) async throws -> User
    func getRegistrationStatus() async throws -> RegistrationStatus
    func verifyAadhaar(token: String) async throws -> User
    func exportData() async throws
    func requestDeletion() async throws
}

struct RegistrationRequest: Sendable {
    let firstName: String
    let lastName: String
    let email: String
    let phone: String
    let dateOfBirth: Date?
    let gender: Gender?
    let bloodGroup: BloodGroup?
    let address: String?
    let role: UserRole
    let doctorProfile: DoctorProfileInput?
    let labTechProfile: LabTechProfileInput?
    let consents: [ConsentInput]
}

struct DoctorProfileInput: Sendable {
    let medicalLicenseNumber: String
    let specialization: String
    let clinicOrHospitalName: String?
    let clinicAddress: String?
}

struct LabTechProfileInput: Sendable {
    let labName: String
    let labLicenseNumber: String?
    let nablAccreditationId: String?
}

struct ConsentInput: Sendable {
    let purpose: ConsentPurpose
    let isGranted: Bool
}
