import Foundation

struct UserProfileResponse: Decodable, Sendable {
    let sub: String
    let firstName: String
    let lastName: String
    let email: String
    let phone: String?
    let address: String?
    let bloodGroup: String?
    let dateOfBirth: String?
    let gender: String?
    let roles: [String]
    let registrationStatus: String
    let isAadhaarVerified: Bool?
    let aadhaarRefToken: String?
}

struct DoctorProfileDTO: Decodable, Sendable {
    let id: String
    let medicalLicenseNumber: String
    let specialization: String
    let clinicOrHospitalName: String?
    let clinicAddress: String?
}

struct LabTechProfileDTO: Decodable, Sendable {
    let id: String
    let labName: String
    let labLicenseNumber: String?
    let nablAccreditationId: String?
}

struct UpdateProfileRequest: Encodable, Sendable {
    let firstName: String
    let lastName: String
    let email: String
    let phone: String
    let address: String?
    let bloodGroup: String?
    let dateOfBirth: String?
    let gender: String?
}

struct RegisterUserRequest: Encodable, Sendable {
    let firstName: String
    let lastName: String
    let email: String
    let phone: String
    let dateOfBirth: String?
    let gender: String?
    let bloodGroup: String?
    let address: String?
    let role: String
    let doctorData: DoctorProfileInputDTO?
    let labTechnicianData: LabTechProfileInputDTO?
    let consents: [ConsentInputDTO]
}

struct DoctorProfileInputDTO: Encodable, Sendable {
    let medicalLicenseNumber: String
    let specialization: String
    let clinicOrHospitalName: String?
    let clinicAddress: String?
}

struct LabTechProfileInputDTO: Encodable, Sendable {
    let labName: String
    let labLicenseNumber: String?
    let nablAccreditationId: String?
}

struct ConsentInputDTO: Encodable, Sendable {
    let purpose: String
    let isGranted: Bool
}

struct RegisterUserResponse: Decodable, Sendable {
    let sub: String
    let role: String
    let registrationStatus: String
    let email: String
    let firstName: String
    let lastName: String
    let phone: String?
    let address: String?
    let bloodGroup: String?
    let dateOfBirth: String?
    let gender: String?
    let consentsGranted: [String]?
    let isAadhaarVerified: Bool?
    let aadhaarRefToken: String?
}

struct RegistrationStatusResponse: Decodable, Sendable {
    let registrationStatus: String
}
