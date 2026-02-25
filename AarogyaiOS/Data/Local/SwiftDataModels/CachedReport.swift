import Foundation
import SwiftData

@Model
final class CachedReport {
    @Attribute(.unique) var reportId: String
    var reportNumber: String
    var title: String
    var reportType: String
    var status: String
    var patientId: String
    var uploadedAt: Date
    var labName: String?
    var highlightParameter: String?
    var lastFetchedAt: Date

    init(
        reportId: String,
        reportNumber: String,
        title: String,
        reportType: String,
        status: String,
        patientId: String,
        uploadedAt: Date,
        labName: String?,
        highlightParameter: String?,
        lastFetchedAt: Date = .now
    ) {
        self.reportId = reportId
        self.reportNumber = reportNumber
        self.title = title
        self.reportType = reportType
        self.status = status
        self.patientId = patientId
        self.uploadedAt = uploadedAt
        self.labName = labName
        self.highlightParameter = highlightParameter
        self.lastFetchedAt = lastFetchedAt
    }

    convenience init(from report: Report) {
        self.init(
            reportId: report.id,
            reportNumber: report.reportNumber,
            title: report.title,
            reportType: report.reportType.rawValue,
            status: report.status.rawValue,
            patientId: report.patientId,
            uploadedAt: report.uploadedAt,
            labName: report.labName,
            highlightParameter: report.highlightParameter
        )
    }

    func toDomain() -> Report {
        Report(
            id: reportId,
            reportNumber: reportNumber,
            title: title,
            reportType: ReportType(rawValue: reportType) ?? .other,
            status: ReportStatus(rawValue: status) ?? .uploaded,
            patientId: patientId,
            doctorId: nil,
            doctorName: nil,
            labName: labName,
            collectedAt: nil,
            reportedAt: nil,
            uploadedAt: uploadedAt,
            notes: nil,
            fileStorageKey: nil,
            fileType: nil,
            fileSizeBytes: nil,
            checksumSha256: nil,
            parameters: [],
            extraction: nil,
            highlightParameter: highlightParameter,
            createdAt: uploadedAt,
            updatedAt: uploadedAt
        )
    }
}
