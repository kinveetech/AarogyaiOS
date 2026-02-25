import Foundation

struct DoctorProfile: Sendable {
    let id: String
    var medicalLicenseNumber: String
    var specialization: String
    var clinicOrHospitalName: String?
    var clinicAddress: String?
}
