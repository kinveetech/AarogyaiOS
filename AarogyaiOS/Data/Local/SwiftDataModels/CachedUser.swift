import Foundation
import SwiftData

@Model
final class CachedUser {
    @Attribute(.unique) var userId: String
    var firstName: String
    var lastName: String
    var email: String
    var phone: String
    var role: String
    var registrationStatus: String
    var lastFetchedAt: Date

    init(
        userId: String,
        firstName: String,
        lastName: String,
        email: String,
        phone: String,
        role: String,
        registrationStatus: String,
        lastFetchedAt: Date = .now
    ) {
        self.userId = userId
        self.firstName = firstName
        self.lastName = lastName
        self.email = email
        self.phone = phone
        self.role = role
        self.registrationStatus = registrationStatus
        self.lastFetchedAt = lastFetchedAt
    }

    convenience init(from user: User) {
        self.init(
            userId: user.id,
            firstName: user.firstName,
            lastName: user.lastName,
            email: user.email,
            phone: user.phone,
            role: user.role.rawValue,
            registrationStatus: user.registrationStatus.rawValue
        )
    }

    func toDomain() -> User {
        User(
            id: userId,
            firstName: firstName,
            lastName: lastName,
            email: email,
            phone: phone,
            address: nil,
            bloodGroup: nil,
            dateOfBirth: nil,
            gender: nil,
            role: UserRole(rawValue: role) ?? .patient,
            registrationStatus: RegistrationStatus(rawValue: registrationStatus) ?? .approved,
            isAadhaarVerified: false,
            aadhaarRefToken: nil,
            doctorProfile: nil,
            labTechProfile: nil,
            createdAt: lastFetchedAt,
            updatedAt: lastFetchedAt
        )
    }
}
