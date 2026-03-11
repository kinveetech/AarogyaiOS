import Foundation

struct AadhaarVerifyRequest: Encodable, Sendable {
    let aadhaarRefToken: String
}

struct AadhaarVerifyResponse: Decodable, Sendable {
    let sub: String
    let firstName: String
    let lastName: String
    let email: String
    let phone: String?
    let address: String?
    let bloodGroup: String?
    let dateOfBirth: String?
    let gender: String?
    let roles: [String]
    let registrationStatus: String
    let isAadhaarVerified: Bool
    let aadhaarRefToken: String?
}
