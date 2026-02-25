import Foundation

enum ExtractionStatus: String, Codable, Sendable {
    case pending
    case inProgress = "in_progress"
    case completed
    case failed
}
