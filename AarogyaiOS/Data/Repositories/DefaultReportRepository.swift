import Foundation
import OSLog

struct DefaultReportRepository: ReportRepository {
    private let apiClient: APIClient
    private let localDataSource: LocalDataSource?

    init(apiClient: APIClient, localDataSource: LocalDataSource? = nil) {
        self.apiClient = apiClient
        self.localDataSource = localDataSource
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

    func getReportsWithCache(
        page: Int,
        pageSize: Int,
        type: ReportType?,
        status: ReportStatus?,
        search: String?
    ) async throws -> CachedResult<PaginatedResult<Report>> {
        do {
            let result = try await getReports(
                page: page, pageSize: pageSize, type: type, status: status, search: search
            )

            // Cache the first page of unfiltered results
            if page == 1 && type == nil && status == nil && search == nil {
                await cacheReports(result.items)
            }

            return CachedResult(data: result, source: .network, lastFetchedAt: .now)
        } catch {
            // Only fall back to cache for page 1 of unfiltered results
            guard page == 1 && type == nil && status == nil && search == nil else {
                throw error
            }

            if let cached = await loadCachedReports() {
                Logger.cache.info("Network failed, serving \(cached.data.items.count) cached reports")
                return cached
            }

            throw error
        }
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
        let report = ReportMapper.toDomain(response)

        await invalidateCache()

        return report
    }

    func deleteReport(id: String) async throws {
        try await apiClient.requestNoContent(.deleteReport(id: id))
        await invalidateCache()
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

    func getVerifiedDownloadURL(reportId: String) async throws -> VerifiedDownload {
        let dto = VerifiedDownloadUrlRequestDTO(reportId: reportId, expiryMinutes: nil)
        let response: VerifiedDownloadUrlResponseDTO = try await apiClient.request(
            .verifiedDownloadUrl, body: dto
        )
        guard let url = URL(string: response.downloadUrl) else {
            throw APIError.decodingError(underlying: URLError(.badURL))
        }
        return VerifiedDownload(
            downloadURL: url,
            checksumSha256: nil,
            isServerVerified: response.checksumVerified
        )
    }

    func getExtractionStatus(reportId: String) async throws -> ReportExtraction {
        let response: ExtractionDTO = try await apiClient.request(.extractionStatus(id: reportId))
        return ReportMapper.toDomain(response)
    }

    func triggerExtraction(reportId: String) async throws {
        try await apiClient.requestNoContent(.triggerExtraction(id: reportId))
    }

    // MARK: - Cache Helpers

    func invalidateCache() async {
        guard let localDataSource else { return }
        do {
            try await localDataSource.deleteAll(CachedReport.self)
            Logger.cache.info("Report cache invalidated")
        } catch {
            Logger.cache.error("Failed to invalidate report cache: \(error)")
        }
    }

    private func cacheReports(_ reports: [Report]) async {
        guard let localDataSource else { return }
        do {
            try await localDataSource.syncReports(reports)
            Logger.cache.info("Cached \(reports.count) reports to SwiftData")
        } catch {
            Logger.cache.error("Failed to cache reports: \(error)")
        }
    }

    private func loadCachedReports() async -> CachedResult<PaginatedResult<Report>>? {
        guard let localDataSource else { return nil }
        do {
            let (reports, lastFetchedAt) = try await localDataSource.fetchCachedReportsAsDomain()
            guard !reports.isEmpty else { return nil }

            let paginated = PaginatedResult(
                items: reports,
                page: 1,
                pageSize: reports.count,
                totalCount: reports.count
            )

            return CachedResult(
                data: paginated,
                source: .cache,
                lastFetchedAt: lastFetchedAt ?? .now
            )
        } catch {
            Logger.cache.error("Failed to load cached reports: \(error)")
            return nil
        }
    }
}
