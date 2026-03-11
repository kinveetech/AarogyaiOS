import Foundation
import Testing
@testable import AarogyaiOS

@Suite("ReportsListViewModel")
@MainActor
struct ReportsListViewModelTests {
    let reportRepo = MockReportRepository()

    func makeSUT() -> ReportsListViewModel {
        let useCase = FetchReportsUseCase(reportRepository: reportRepo)
        return ReportsListViewModel(fetchReportsUseCase: useCase)
    }

    @Test func loadReportsSuccess() async {
        let sut = makeSUT()
        await sut.loadReports()
        #expect(sut.reports.count == 1)
        #expect(sut.error == nil)
        #expect(!sut.isLoading)
        #expect(!sut.isFromCache)
    }

    @Test func loadReportsFailure() async {
        reportRepo.getReportsResult = .failure(APIError.serverError(status: 500))
        reportRepo.getReportsWithCacheResult = .failure(APIError.serverError(status: 500))
        let sut = makeSUT()
        await sut.loadReports()
        #expect(sut.reports.isEmpty)
        #expect(sut.error == "Failed to load reports")
    }

    @Test func loadMoreAppends() async {
        reportRepo.getReportsResult = .success(
            PaginatedResult(
                items: Array(repeating: Report.stub, count: 20),
                page: 1, pageSize: 20, totalCount: 40
            )
        )
        let sut = makeSUT()
        await sut.loadReports()
        #expect(sut.reports.count == 20)
        #expect(sut.hasMorePages)

        reportRepo.getReportsResult = .success(
            PaginatedResult(items: [.stub], page: 2, pageSize: 20, totalCount: 40)
        )
        await sut.loadMore()
        #expect(sut.reports.count == 21)
    }

    @Test func loadMoreDoesNothingWhenNoMorePages() async {
        reportRepo.getReportsResult = .success(
            PaginatedResult(items: [.stub], page: 1, pageSize: 20, totalCount: 1)
        )
        let sut = makeSUT()
        await sut.loadReports()
        #expect(!sut.hasMorePages)

        let callCountBefore = reportRepo.getReportsCallCount
        await sut.loadMore()
        #expect(reportRepo.getReportsCallCount == callCountBefore)
    }

    @Test func refreshReloadsReports() async {
        let sut = makeSUT()
        await sut.refresh()
        #expect(sut.reports.count == 1)
        #expect(reportRepo.getReportsWithCacheCallCount == 1)
    }

    @Test func loadReportsFromCacheShowsOfflineMessage() async {
        let cachedResult = CachedResult(
            data: PaginatedResult(items: [.stub], page: 1, pageSize: 1, totalCount: 1),
            source: CachedResult<PaginatedResult<Report>>.DataSource.cache,
            lastFetchedAt: Date.now.addingTimeInterval(-300)
        )
        reportRepo.getReportsWithCacheResult = .success(cachedResult)

        let sut = makeSUT()
        await sut.loadReports()

        #expect(sut.reports.count == 1)
        #expect(sut.isFromCache)
        #expect(sut.error == "Showing offline data")
        #expect(sut.stalenessText == "Last updated 5 min ago")
    }

    @Test func stalenessTextNilWhenFromNetwork() async {
        let sut = makeSUT()
        await sut.loadReports()
        #expect(sut.stalenessText == nil)
    }
}
