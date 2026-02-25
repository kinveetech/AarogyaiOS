import Foundation

struct DefaultReportRepository: ReportRepository {
    private let apiClient: APIClient

    init(apiClient: APIClient) {
        self.apiClient = apiClient
    }

    func getReports(
        page: Int,
        pageSize: Int,
        type: ReportType?,
        status: ReportStatus?,
        search: String?
    ) async throws -> PaginatedResult<Report> {
        let response: PaginatedDTO<ReportSummaryDTO> = try await apiClient.request(
            .reportsList(
                page: page,
                pageSize: pageSize,
                type: type?.rawValue,
                status: status?.rawValue,
                search: search
            )
        )
        return PaginatedResult(
            items: response.items.map { ReportMapper.toDomain($0) },
            page: response.page,
            pageSize: response.pageSize,
            totalCount: response.totalCount
        )
    }

    func getReport(id: String) async throws -> Report {
        let response: ReportDetailDTO = try await apiClient.request(.reportDetail(id: id))
        return ReportMapper.toDomain(response)
    }

    func createReport(request: CreateReportInput) async throws -> Report {
        let dto = CreateReportRequestDTO(
            fileStorageKey: request.fileStorageKey,
            reportType: request.reportType.rawValue,
            title: request.title,
            reportDate: request.reportDate?.iso8601String,
            doctorName: request.doctorName,
            labName: request.labName,
            notes: request.notes
        )
        let response: ReportDetailDTO = try await apiClient.request(.createReport, body: dto)
        return ReportMapper.toDomain(response)
    }

    func deleteReport(id: String) async throws {
        try await apiClient.requestNoContent(.deleteReport(id: id))
    }

    func getUploadURL(fileName: String, contentType: String) async throws -> PresignedUpload {
        let dto = UploadUrlRequestDTO(fileName: fileName, contentType: contentType)
        let response: UploadUrlResponseDTO = try await apiClient.request(.uploadUrl, body: dto)
        guard let url = URL(string: response.uploadUrl) else {
            throw APIError.decodingError(underlying: URLError(.badURL))
        }
        return PresignedUpload(uploadURL: url, fileStorageKey: response.fileStorageKey)
    }

    func getDownloadURL(reportId: String) async throws -> URL {
        let dto = DownloadUrlRequestDTO(reportId: reportId)
        let response: DownloadUrlResponseDTO = try await apiClient.request(.downloadUrl, body: dto)
        guard let url = URL(string: response.downloadUrl) else {
            throw APIError.decodingError(underlying: URLError(.badURL))
        }
        return url
    }

    func getExtractionStatus(reportId: String) async throws -> ReportExtraction {
        let response: ExtractionDTO = try await apiClient.request(.extractionStatus(id: reportId))
        return ReportMapper.toDomain(response)
    }

    func triggerExtraction(reportId: String) async throws {
        try await apiClient.requestNoContent(.triggerExtraction(id: reportId))
    }
}
