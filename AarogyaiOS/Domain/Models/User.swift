import Foundation

struct User: Identifiable, Sendable {
    let id: String
    var firstName: String
    var lastName: String
    var email: String
    var phone: String
    var address: String?
    var bloodGroup: BloodGroup?
    var dateOfBirth: Date?
    var gender: Gender?
    var role: UserRole
    var registrationStatus: RegistrationStatus
    var isAadhaarVerified: Bool
    var aadhaarRefToken: String?
    var doctorProfile: DoctorProfile?
    var labTechProfile: LabTechnicianProfile?
    var createdAt: Date
    var updatedAt: Date
}
