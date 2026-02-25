import Foundation

struct OtpRequestDTO: Encodable, Sendable {
    let phone: String
}

struct OtpVerifyRequest: Encodable, Sendable {
    let phone: String
    let otp: String
}
