import Foundation

struct EmergencyContactResponse: Decodable, Sendable {
    let id: String
    let name: String
    let phone: String
    let relationship: String
    let isPrimary: Bool
    let createdAt: String
    let updatedAt: String
}

struct EmergencyContactRequestDTO: Encodable, Sendable {
    let name: String
    let phone: String
    let relationship: String
    let isPrimary: Bool
}

struct EmergencyAccessRequestDTO: Encodable, Sendable {
    let patientSub: String
    let emergencyContactPhone: String
    let doctorSub: String
    let reason: String
    let durationHours: Int?
}

struct EmergencyAccessResponseDTO: Decodable, Sendable {
    let grantId: String
    let patientSub: String
    let doctorSub: String
    let emergencyContactId: String
    let startsAt: String
    let expiresAt: String
    let purpose: String
}
