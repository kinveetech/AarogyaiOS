import Foundation

struct EmergencyContact: Identifiable, Sendable {
    let id: String
    var name: String
    var phone: String
    var relationship: Relationship
    var isPrimary: Bool
    var createdAt: Date
    var updatedAt: Date
}
