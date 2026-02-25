import Foundation

enum AccessGrantStatus: String, Codable, Sendable {
    case active
    case revoked
    case expired
}
