import Foundation

struct UploadReportUseCase: Sendable {
    private let reportRepository: any ReportRepository
    private let uploadService: any FileUploading

    init(reportRepository: any ReportRepository, uploadService: any FileUploading) {
        self.reportRepository = reportRepository
        self.uploadService = uploadService
    }

    func execute(
        input: UploadReportInput,
        onProgress: @Sendable @escaping (Double) -> Void
    ) async throws -> Report {
        let presigned = try await reportRepository.getUploadURL(
            fileName: input.fileName,
            contentType: input.contentType
        )

        try await uploadService.upload(
            data: input.fileData,
            to: presigned.uploadURL,
            contentType: input.contentType,
            onProgress: onProgress
        )

        return try await reportRepository.createReport(
            request: CreateReportInput(
                fileStorageKey: presigned.fileStorageKey,
                reportType: input.reportType,
                title: input.title,
                reportDate: input.reportDate,
                doctorName: input.doctorName,
                labName: input.labName,
                notes: input.notes
            )
        )
    }
}

struct UploadReportInput: Sendable {
    let fileData: Data
    let fileName: String
    let contentType: String
    let reportType: ReportType
    let title: String?
    let reportDate: Date?
    let doctorName: String?
    let labName: String?
    let notes: String?
}

protocol FileUploading: Sendable {
    func upload(data: Data, to url: URL, contentType: String, onProgress: @Sendable @escaping (Double) -> Void) async throws
}
