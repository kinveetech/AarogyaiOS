import Foundation

struct FetchReportsUseCase: Sendable {
    private let reportRepository: any ReportRepository

    init(reportRepository: any ReportRepository) {
        self.reportRepository = reportRepository
    }

    func execute(
        page: Int = 1,
        pageSize: Int = 20,
        type: ReportType? = nil,
        status: ReportStatus? = nil,
        search: String? = nil
    ) async throws -> PaginatedResult<Report> {
        try await reportRepository.getReports(
            page: page,
            pageSize: pageSize,
            type: type,
            status: status,
            search: search
        )
    }

    func executeWithCache(
        page: Int = 1,
        pageSize: Int = 20,
        type: ReportType? = nil,
        status: ReportStatus? = nil,
        search: String? = nil
    ) async throws -> CachedResult<PaginatedResult<Report>> {
        try await reportRepository.getReportsWithCache(
            page: page,
            pageSize: pageSize,
            type: type,
            status: status,
            search: search
        )
    }
}
