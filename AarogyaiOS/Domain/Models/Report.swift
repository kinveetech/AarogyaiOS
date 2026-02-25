import Foundation

struct Report: Identifiable, Sendable {
    let id: String
    let reportNumber: String
    var title: String
    var reportType: ReportType
    var status: ReportStatus
    var patientId: String
    var doctorId: String?
    var doctorName: String?
    var labName: String?
    var collectedAt: Date?
    var reportedAt: Date?
    var uploadedAt: Date
    var notes: String?
    var fileStorageKey: String?
    var fileType: String?
    var fileSizeBytes: Int?
    var checksumSha256: String?
    var parameters: [ReportParameter]
    var extraction: ReportExtraction?
    var highlightParameter: String?
    var createdAt: Date
    var updatedAt: Date
}
