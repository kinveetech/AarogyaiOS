import Foundation

enum ReportStatus: String, Codable, Sendable {
    case draft
    case uploaded
    case processing
    case clean
    case infected
    case validated
    case published
    case archived
    case extracting
    case extracted
    case extractionFailed = "extraction_failed"
}
