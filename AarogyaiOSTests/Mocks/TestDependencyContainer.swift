import Foundation
@testable import AarogyaiOS

extension User {
    static func stub(registrationStatus: RegistrationStatus = .approved) -> User {
        User(
            id: "user-1",
            firstName: "Test",
            lastName: "User",
            email: "test@example.com",
            phone: "+911234567890",
            address: nil,
            bloodGroup: .oPositive,
            dateOfBirth: Date(timeIntervalSince1970: 946_684_800),
            gender: .male,
            role: .patient,
            registrationStatus: registrationStatus,
            isAadhaarVerified: false,
            aadhaarRefToken: nil,
            doctorProfile: nil,
            labTechProfile: nil,
            createdAt: .now,
            updatedAt: .now
        )
    }
}
