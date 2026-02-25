import Foundation

enum ReportMapper {
    static func toDomain(_ dto: ReportDetailDTO) -> Report {
        Report(
            id: dto.reportId,
            reportNumber: dto.reportNumber,
            title: dto.title,
            reportType: ReportType(rawValue: dto.reportType) ?? .other,
            status: ReportStatus(rawValue: dto.status) ?? .draft,
            patientId: dto.patientId,
            doctorId: dto.doctorId,
            doctorName: dto.doctorName,
            labName: dto.labName,
            collectedAt: dto.collectedAt.flatMap { Date(iso8601: $0) },
            reportedAt: dto.reportedAt.flatMap { Date(iso8601: $0) },
            uploadedAt: Date(iso8601: dto.uploadedAt) ?? .now,
            notes: dto.notes,
            fileStorageKey: dto.fileStorageKey,
            fileType: dto.fileType,
            fileSizeBytes: dto.fileSizeBytes,
            checksumSha256: dto.checksumSha256,
            parameters: dto.parameters?.map { toDomain($0) } ?? [],
            extraction: dto.extraction.map { toDomain($0) },
            highlightParameter: dto.highlightParameter,
            createdAt: Date(iso8601: dto.createdAt) ?? .now,
            updatedAt: Date(iso8601: dto.updatedAt) ?? .now
        )
    }

    static func toDomain(_ dto: ReportSummaryDTO) -> Report {
        Report(
            id: dto.reportId,
            reportNumber: dto.reportNumber,
            title: dto.title,
            reportType: ReportType(rawValue: dto.reportType) ?? .other,
            status: ReportStatus(rawValue: dto.status) ?? .draft,
            patientId: dto.patientId,
            doctorId: nil,
            doctorName: nil,
            labName: dto.labName,
            collectedAt: nil,
            reportedAt: nil,
            uploadedAt: Date(iso8601: dto.uploadedAt) ?? .now,
            notes: nil,
            fileStorageKey: nil,
            fileType: nil,
            fileSizeBytes: nil,
            checksumSha256: nil,
            parameters: [],
            extraction: nil,
            highlightParameter: dto.highlightParameter,
            createdAt: .now,
            updatedAt: .now
        )
    }

    static func toDomain(_ dto: ReportParameterDTO) -> ReportParameter {
        ReportParameter(
            id: dto.code,
            code: dto.code,
            name: dto.name,
            numericValue: dto.numericValue,
            textValue: dto.textValue,
            unit: dto.unit,
            referenceRange: dto.referenceRange,
            isAbnormal: dto.isAbnormal
        )
    }

    static func toDomain(_ dto: ExtractionDTO) -> ReportExtraction {
        ReportExtraction(
            status: ExtractionStatus(rawValue: dto.status) ?? .pending,
            extractionMethod: dto.extractionMethod,
            structuringModel: dto.structuringModel,
            extractedParameterCount: dto.extractedParameterCount,
            overallConfidence: dto.overallConfidence,
            pageCount: dto.pageCount,
            extractedAt: dto.extractedAt.flatMap { Date(iso8601: $0) },
            errorMessage: dto.errorMessage,
            attemptCount: dto.attemptCount
        )
    }
}
