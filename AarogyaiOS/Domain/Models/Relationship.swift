import Foundation

enum Relationship: String, Codable, CaseIterable, Sendable {
    case spouse
    case parent
    case sibling
    case child
    case friend
    case other
}
