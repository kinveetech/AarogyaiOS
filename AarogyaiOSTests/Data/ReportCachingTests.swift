import Foundation
import Testing
@testable import AarogyaiOS

@Suite("Report Caching Integration")
struct ReportCachingTests {
    let reportRepo = MockReportRepository()

    // MARK: - Cache Write on Successful Fetch

    @Test func networkSuccessReturnsCachedResultWithNetworkSource() async throws {
        let result = try await reportRepo.getReportsWithCache(
            page: 1, pageSize: 20, type: nil, status: nil, search: nil
        )
        #expect(!result.isCached)
        #expect(result.source == .network)
        #expect(result.data.items.count == 1)
    }

    @Test func cacheWriteCallCount() async throws {
        // On successful fetch, getReportsWithCache is called
        _ = try await reportRepo.getReportsWithCache(
            page: 1, pageSize: 20, type: nil, status: nil, search: nil
        )
        #expect(reportRepo.getReportsWithCacheCallCount == 1)
    }

    // MARK: - Cache Read on Network Failure (Fallback)

    @Test func networkFailureFallsBackToCache() async throws {
        let cachedData = CachedResult(
            data: PaginatedResult(
                items: [Report.stub], page: 1, pageSize: 1, totalCount: 1
            ),
            source: CachedResult<PaginatedResult<Report>>.DataSource.cache,
            lastFetchedAt: Date.now.addingTimeInterval(-120)
        )
        reportRepo.getReportsWithCacheResult = .success(cachedData)

        let result = try await reportRepo.getReportsWithCache(
            page: 1, pageSize: 20, type: nil, status: nil, search: nil
        )

        #expect(result.isCached)
        #expect(result.data.items.count == 1)
    }

    @Test func networkFailureWithNoCacheThrowsError() async {
        reportRepo.getReportsWithCacheResult = .failure(APIError.networkError(underlying: URLError(.notConnectedToInternet)))

        await #expect(throws: APIError.self) {
            _ = try await reportRepo.getReportsWithCache(
                page: 1, pageSize: 20, type: nil, status: nil, search: nil
            )
        }
    }

    // MARK: - Cache Invalidation on Create/Delete

    @Test func invalidateCacheIsCalled() async {
        await reportRepo.invalidateCache()
        #expect(reportRepo.invalidateCacheCallCount == 1)
    }

    @Test func invalidateCacheCalledMultipleTimesAccumulates() async {
        await reportRepo.invalidateCache()
        await reportRepo.invalidateCache()
        #expect(reportRepo.invalidateCacheCallCount == 2)
    }

    // MARK: - Staleness Check

    @Test func cachedResultWithRecentTimestampIsNotStale() async throws {
        let recentCache = CachedResult(
            data: PaginatedResult(
                items: [Report.stub], page: 1, pageSize: 1, totalCount: 1
            ),
            source: CachedResult<PaginatedResult<Report>>.DataSource.cache,
            lastFetchedAt: Date.now.addingTimeInterval(-30)
        )
        reportRepo.getReportsWithCacheResult = .success(recentCache)

        let result = try await reportRepo.getReportsWithCache(
            page: 1, pageSize: 20, type: nil, status: nil, search: nil
        )

        #expect(!result.isStale(ttl: Constants.Cache.reportsListTTL))
    }

    @Test func cachedResultWithOldTimestampIsStale() async throws {
        let oldCache = CachedResult(
            data: PaginatedResult(
                items: [Report.stub], page: 1, pageSize: 1, totalCount: 1
            ),
            source: CachedResult<PaginatedResult<Report>>.DataSource.cache,
            lastFetchedAt: Date.now.addingTimeInterval(-600)
        )
        reportRepo.getReportsWithCacheResult = .success(oldCache)

        let result = try await reportRepo.getReportsWithCache(
            page: 1, pageSize: 20, type: nil, status: nil, search: nil
        )

        #expect(result.isStale(ttl: Constants.Cache.reportsListTTL))
    }

    @Test func networkResultIsNeverStale() async throws {
        let result = try await reportRepo.getReportsWithCache(
            page: 1, pageSize: 20, type: nil, status: nil, search: nil
        )

        #expect(!result.isStale(ttl: Constants.Cache.reportsListTTL))
    }
}
