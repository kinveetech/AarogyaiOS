import Foundation

struct ReportExtraction: Sendable {
    var status: ExtractionStatus
    var extractionMethod: String?
    var structuringModel: String?
    var extractedParameterCount: Int
    var overallConfidence: Double?
    var pageCount: Int?
    var extractedAt: Date?
    var errorMessage: String?
    var attemptCount: Int
}
