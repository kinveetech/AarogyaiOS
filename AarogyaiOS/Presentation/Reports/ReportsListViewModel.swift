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

    private var currentPage = 1
    private let pageSize = Constants.Pagination.defaultPageSize
    private let fetchReportsUseCase: FetchReportsUseCase

    init(fetchReportsUseCase: FetchReportsUseCase) {
        self.fetchReportsUseCase = fetchReportsUseCase
    }

    func loadReports() async {
        isLoading = true
        error = nil
        currentPage = 1

        do {
            let result = try await fetchReportsUseCase.execute(
                page: 1,
                pageSize: pageSize,
                type: selectedFilter,
                search: searchQuery.isEmpty ? nil : searchQuery
            )
            reports = result.items
            hasMorePages = result.items.count >= pageSize
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
