import Foundation

struct ReportSummaryDTO: Decodable, Sendable {
    let reportId: String
    let reportNumber: String
    let title: String
    let reportType: String
    let status: String
    let patientId: String
    let uploadedAt: String
    let labName: String?
    let highlightParameter: String?
}

struct ReportDetailDTO: Decodable, Sendable {
    let reportId: String
    let reportNumber: String
    let title: String
    let reportType: String
    let status: String
    let patientId: String
    let doctorId: String?
    let doctorName: String?
    let labName: String?
    let collectedAt: String?
    let reportedAt: String?
    let uploadedAt: String
    let notes: String?
    let fileStorageKey: String?
    let fileType: String?
    let fileSizeBytes: Int?
    let checksumSha256: String?
    let parameters: [ReportParameterDTO]?
    let extraction: ExtractionDTO?
    let highlightParameter: String?
    let createdAt: String
    let updatedAt: String
}

struct ReportParameterDTO: Decodable, Sendable {
    let code: String
    let name: String
    let numericValue: Double?
    let textValue: String?
    let unit: String?
    let referenceRange: String?
    let isAbnormal: Bool
}

struct ExtractionDTO: Decodable, Sendable {
    let status: String
    let extractionMethod: String?
    let structuringModel: String?
    let extractedParameterCount: Int
    let overallConfidence: Double?
    let pageCount: Int?
    let extractedAt: String?
    let errorMessage: String?
    let attemptCount: Int
}

struct CreateReportRequestDTO: Encodable, Sendable {
    let objectKey: String
    let reportType: String
    let labName: String?
    let parameters: [ReportParameterRequestDTO]
    let notes: String?
    let collectedAt: String?
    let reportedAt: String?
}

struct ReportParameterRequestDTO: Encodable, Sendable {
    let code: String
    let name: String
    let numericValue: Double?
    let textValue: String?
    let unit: String?
    let referenceRange: String?
    let isAbnormal: Bool?
}

struct UploadUrlRequestDTO: Encodable, Sendable {
    let fileName: String
    let contentType: String
}

struct UploadUrlResponseDTO: Decodable, Sendable {
    let uploadUrl: String
    let fileStorageKey: String
    let expiresAt: String
}

struct DownloadUrlRequestDTO: Encodable, Sendable {
    let reportId: String
}

struct DownloadUrlResponseDTO: Decodable, Sendable {
    let downloadUrl: String
    let expiresAt: String
    let checksumSha256: String?
}

struct VerifiedDownloadUrlRequestDTO: Encodable, Sendable {
    let reportId: String
    let expiryMinutes: Int?
}

struct VerifiedDownloadUrlResponseDTO: Decodable, Sendable {
    let reportId: String
    let objectKey: String
    let downloadUrl: String
    let expiresAt: String
    let checksumVerified: Bool
}
