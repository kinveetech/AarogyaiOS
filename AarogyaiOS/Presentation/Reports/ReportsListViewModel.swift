import Foundation
import OSLog

@Observable
@MainActor
final class ReportsListViewModel {
    var reports: [Report] = []
    var selectedFilter: ReportType?
    var searchQuery: String = ""
    var isLoading = false
    var isLoadingMore = false
    var error: String?
    var hasMorePages = true
    var isFromCache = false
    var lastFetchedAt: Date?
    var needsRefresh = false

    private var currentPage = 1
    private let pageSize = Constants.Pagination.defaultPageSize
    private let fetchReportsUseCase: FetchReportsUseCase

    init(fetchReportsUseCase: FetchReportsUseCase) {
        self.fetchReportsUseCase = fetchReportsUseCase
    }

    /// Human-readable staleness indicator, e.g. "Last updated 5 min ago"
    var stalenessText: String? {
        guard isFromCache, let lastFetchedAt else { return nil }
        let elapsed = Date.now.timeIntervalSince(lastFetchedAt)

        if elapsed < 60 {
            return "Last updated just now"
        } else if elapsed < 3600 {
            let minutes = Int(elapsed / 60)
            return "Last updated \(minutes) min ago"
        } else {
            let hours = Int(elapsed / 3600)
            return "Last updated \(hours) hr ago"
        }
    }

    func loadReports() async {
        isLoading = true
        error = nil
        currentPage = 1

        do {
            let result = try await fetchReportsUseCase.executeWithCache(
                page: 1,
                pageSize: pageSize,
                type: selectedFilter,
                search: searchQuery.isEmpty ? nil : searchQuery
            )
            reports = result.data.items
            hasMorePages = result.data.items.count >= pageSize
            isFromCache = result.isCached
            lastFetchedAt = result.lastFetchedAt

            if result.isCached {
                self.error = "Showing offline data"
            }
        } catch {
            self.error = "Failed to load reports"
            Logger.data.error("Load reports failed: \(error)")
        }

        isLoading = false
    }

    func loadMore() async {
        guard hasMorePages, !isLoadingMore else { return }

        isLoadingMore = true
        let nextPage = currentPage + 1

        do {
            let result = try await fetchReportsUseCase.execute(
                page: nextPage,
                pageSize: pageSize,
                type: selectedFilter,
                search: searchQuery.isEmpty ? nil : searchQuery
            )
            reports.append(contentsOf: result.items)
            currentPage = nextPage
            hasMorePages = result.items.count >= pageSize
        } catch {
            Logger.data.error("Load more reports failed: \(error)")
        }

        isLoadingMore = false
    }

    func markNeedsRefresh() {
        needsRefresh = true
    }

    func refreshIfNeeded() async {
        guard needsRefresh else { return }
        needsRefresh = false
        await loadReports()
    }

    func refresh() async {
        await loadReports()
    }

    func applyFilter(_ filter: ReportType?) {
        selectedFilter = filter
        Task { await loadReports() }
    }

    func search() {
        Task { await loadReports() }
    }
}
