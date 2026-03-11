import Foundation

struct VerifiedDownload: Sendable {
    let downloadURL: URL
    let checksumSha256: String?
    let isServerVerified: Bool
}
