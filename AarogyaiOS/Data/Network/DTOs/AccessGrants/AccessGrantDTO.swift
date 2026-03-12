import Foundation

struct AccessGrantResponse: Decodable, Sendable {
    let id: String
    let patientId: String
    let grantedToUserId: String
    let grantedToUserName: String?
    let grantedByUserId: String
    let grantedByUserName: String?
    let grantReason: String?
    let allReports: Bool
    let reportIds: [String]?
    let status: String
    let startsAt: String
    let expiresAt: String?
    let revokedAt: String?
    let createdAt: String
}

struct CreateAccessGrantRequestDTO: Encodable, Sendable {
    let grantedToUserId: String
    let allReports: Bool
    let reportIds: [String]?
    let grantReason: String?
    let expiresAt: String?
}
