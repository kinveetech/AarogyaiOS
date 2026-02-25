import Foundation

enum RegistrationStatus: String, Codable, Sendable {
    case registered
    case pendingApproval = "pending_approval"
    case approved
    case rejected
}
