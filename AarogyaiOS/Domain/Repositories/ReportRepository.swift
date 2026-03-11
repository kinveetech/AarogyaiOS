import Foundation

protocol ReportRepository: Sendable {
    func getReports(
        page: Int, pageSize: Int, type: ReportType?,
        status: ReportStatus?, search: String?
    ) async throws -> PaginatedResult<Report>

    func getReportsWithCache(
        page: Int, pageSize: Int, type: ReportType?,
        status: ReportStatus?, search: String?
    ) async throws -> CachedResult<PaginatedResult<Report>>
    func getReport(id: String) async throws -> Report
    func createReport(request: CreateReportInput) async throws -> Report
    func deleteReport(id: String) async throws
    func getUploadURL(fileName: String, contentType: String) async throws -> PresignedUpload
    func getDownloadURL(reportId: String) async throws -> URL
    func getVerifiedDownloadURL(reportId: String) async throws -> VerifiedDownload
    func getExtractionStatus(reportId: String) async throws -> ReportExtraction
    func triggerExtraction(reportId: String) async throws
    func invalidateCache() async
}

extension ReportRepository {
    func getReportsWithCache(
        page: Int, pageSize: Int, type: ReportType?,
        status: ReportStatus?, search: String?
    ) async throws -> CachedResult<PaginatedResult<Report>> {
        let result = try await getReports(
            page: page, pageSize: pageSize, type: type, status: status, search: search
        )
        return CachedResult(data: result, source: .network, lastFetchedAt: nil)
    }

    func invalidateCache() async {}
}

struct PaginatedResult<T: Sendable>: Sendable {
    let items: [T]
    let page: Int
    let pageSize: Int
    let totalCount: Int

    var totalPages: Int {
        guard pageSize > 0 else { return 0 }
        return (totalCount + pageSize - 1) / pageSize
    }

    var hasMore: Bool {
        page < totalPages
    }
}

struct CreateReportInput: Sendable {
    let fileStorageKey: String
    let reportType: ReportType
    let title: String?
    let reportDate: Date?
    let doctorName: String?
    let labName: String?
    let notes: String?
}

struct PresignedUpload: Sendable {
    let uploadURL: URL
    let fileStorageKey: String
}
