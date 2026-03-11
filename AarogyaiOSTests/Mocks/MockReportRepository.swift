import Foundation
@testable import AarogyaiOS

final class MockReportRepository: ReportRepository, @unchecked Sendable {
    var getReportsResult: Result<PaginatedResult<Report>, Error> = .success(
        PaginatedResult(items: [.stub], page: 1, pageSize: 20, totalCount: 1)
    )
    var getReportsWithCacheResult: Result<CachedResult<PaginatedResult<Report>>, Error>?
    var getReportResult: Result<Report, Error> = .success(.stub)
    var createReportResult: Result<Report, Error> = .success(.stub)
    var deleteReportResult: Result<Void, Error> = .success(())
    var getUploadURLResult: Result<PresignedUpload, Error> = .success(
        PresignedUpload(uploadURL: URL(string: "https://s3.example.com/upload")!, fileStorageKey: "key")
    )
    var getDownloadURLResult: Result<URL, Error> = .success(URL(string: "https://cdn.example.com/report.pdf")!)
    var getExtractionStatusResult: Result<ReportExtraction, Error> = .success(
        ReportExtraction(
            status: .completed, extractionMethod: nil, structuringModel: nil,
            extractedParameterCount: 0, overallConfidence: nil, pageCount: nil,
            extractedAt: nil, errorMessage: nil, attemptCount: 1
        )
    )
    var triggerExtractionResult: Result<Void, Error> = .success(())

    var getReportsCallCount = 0
    var getReportsWithCacheCallCount = 0
    var getReportCallCount = 0
    var createReportCallCount = 0
    var deleteReportCallCount = 0
    var getUploadURLCallCount = 0
    var getDownloadURLCallCount = 0
    var invalidateCacheCallCount = 0

    var lastGetReportsPage: Int?
    var lastDeletedReportId: String?

    func getReports(
        page: Int, pageSize: Int, type: ReportType?,
        status: ReportStatus?, search: String?
    ) async throws -> PaginatedResult<Report> {
        getReportsCallCount += 1
        lastGetReportsPage = page
        return try getReportsResult.get()
    }

    func getReportsWithCache(
        page: Int, pageSize: Int, type: ReportType?,
        status: ReportStatus?, search: String?
    ) async throws -> CachedResult<PaginatedResult<Report>> {
        getReportsWithCacheCallCount += 1
        lastGetReportsPage = page

        if let overrideResult = getReportsWithCacheResult {
            return try overrideResult.get()
        }

        // Default: wrap getReports result as a network response
        let result = try getReportsResult.get()
        return CachedResult(data: result, source: .network, lastFetchedAt: .now)
    }

    func getReport(id: String) async throws -> Report {
        getReportCallCount += 1
        return try getReportResult.get()
    }

    func createReport(request: CreateReportInput) async throws -> Report {
        createReportCallCount += 1
        return try createReportResult.get()
    }

    func deleteReport(id: String) async throws {
        deleteReportCallCount += 1
        lastDeletedReportId = id
        try deleteReportResult.get()
    }

    func getUploadURL(fileName: String, contentType: String) async throws -> PresignedUpload {
        getUploadURLCallCount += 1
        return try getUploadURLResult.get()
    }

    func getDownloadURL(reportId: String) async throws -> URL {
        getDownloadURLCallCount += 1
        return try getDownloadURLResult.get()
    }

    func getExtractionStatus(reportId: String) async throws -> ReportExtraction {
        try getExtractionStatusResult.get()
    }

    func triggerExtraction(reportId: String) async throws {
        try triggerExtractionResult.get()
    }

    func invalidateCache() async {
        invalidateCacheCallCount += 1
    }
}
