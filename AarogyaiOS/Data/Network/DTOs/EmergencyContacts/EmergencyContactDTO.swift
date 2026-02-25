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
    let contactPhone: String
}
