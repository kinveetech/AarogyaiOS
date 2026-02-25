import Foundation
import SwiftData

@Model
final class CachedEmergencyContact {
    @Attribute(.unique) var contactId: String
    var name: String
    var phone: String
    var relationship: String
    var isPrimary: Bool
    var lastFetchedAt: Date

    init(
        contactId: String,
        name: String,
        phone: String,
        relationship: String,
        isPrimary: Bool,
        lastFetchedAt: Date = .now
    ) {
        self.contactId = contactId
        self.name = name
        self.phone = phone
        self.relationship = relationship
        self.isPrimary = isPrimary
        self.lastFetchedAt = lastFetchedAt
    }

    convenience init(from contact: EmergencyContact) {
        self.init(
            contactId: contact.id,
            name: contact.name,
            phone: contact.phone,
            relationship: contact.relationship.rawValue,
            isPrimary: contact.isPrimary
        )
    }

    func toDomain() -> EmergencyContact {
        EmergencyContact(
            id: contactId,
            name: name,
            phone: phone,
            relationship: Relationship(rawValue: relationship) ?? .other,
            isPrimary: isPrimary,
            createdAt: lastFetchedAt,
            updatedAt: lastFetchedAt
        )
    }
}
