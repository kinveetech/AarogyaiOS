import Foundation
import Testing
@testable import AarogyaiOS

private final class CallTracker: @unchecked Sendable {
    var called = false
}

@Suite("ReportDetailViewModel")
@MainActor
struct ReportDetailViewModelTests {
    let reportRepo = MockReportRepository()

    func makeSUT(
        reportId: String = "report-1",
        onDelete: (@Sendable () -> Void)? = nil
    ) -> ReportDetailViewModel {
        let fetchUseCase = FetchReportsUseCase(reportRepository: reportRepo)
        let downloadUseCase = DownloadReportUseCase(reportRepository: reportRepo)
        let deleteUseCase = DeleteReportUseCase(reportRepository: reportRepo)
        let extractionUseCase = ExtractionUseCase(reportRepository: reportRepo)
        return ReportDetailViewModel(
            reportId: reportId,
            fetchReportsUseCase: fetchUseCase,
            downloadReportUseCase: downloadUseCase,
            deleteReportUseCase: deleteUseCase,
            extractionUseCase: extractionUseCase,
            onDelete: onDelete
        )
    }

    // MARK: - Load Report

    @Test func loadReportSuccess() async {
        let sut = makeSUT()

        await sut.loadReport()

        #expect(sut.report != nil)
        #expect(sut.error == nil)
        #expect(!sut.isLoading)
    }

    @Test func loadReportCreatesExtractionViewModel() async {
        let sut = makeSUT()

        await sut.loadReport()

        #expect(sut.extractionViewModel != nil)
    }

    @Test func loadReportFailure() async {
        reportRepo.getReportsResult = .failure(APIError.serverError(status: 500))
        let sut = makeSUT()

        await sut.loadReport()

        #expect(sut.report == nil)
        #expect(sut.error == "Failed to load report details")
        #expect(sut.extractionViewModel == nil)
    }

    @Test func loadReportNoExtractionViewModelWhenNoReport() async {
        reportRepo.getReportsResult = .success(
            PaginatedResult(items: [], page: 1, pageSize: 20, totalCount: 0)
        )
        let sut = makeSUT()

        await sut.loadReport()

        #expect(sut.report == nil)
        #expect(sut.extractionViewModel == nil)
    }

    // MARK: - Download

    @Test func downloadSuccess() async {
        let sut = makeSUT()

        await sut.download()

        #expect(sut.downloadURL != nil)
        #expect(sut.error == nil)
    }

    @Test func downloadFailure() async {
        reportRepo.getDownloadURLResult = .failure(APIError.serverError(status: 500))
        let sut = makeSUT()

        await sut.download()

        #expect(sut.downloadURL == nil)
        #expect(sut.error == "Failed to generate download link")
    }

    // MARK: - Delete

    @Test func deleteReportSuccess() async {
        let sut = makeSUT()

        let result = await sut.deleteReport()

        #expect(result)
        #expect(!sut.isDeleting)
        #expect(sut.error == nil)
    }

    @Test func deleteReportCallsRepositoryWithCorrectId() async {
        let sut = makeSUT(reportId: "report-42")

        _ = await sut.deleteReport()

        #expect(reportRepo.deleteReportCallCount == 1)
        #expect(reportRepo.lastDeletedReportId == "report-42")
    }

    @Test func deleteReportFailure() async {
        reportRepo.deleteReportResult = .failure(APIError.serverError(status: 500))
        let sut = makeSUT()

        let result = await sut.deleteReport()

        #expect(!result)
        #expect(sut.error == "Failed to delete report")
        #expect(!sut.isDeleting)
    }

    @Test func deleteReportFailureDoesNotClearExistingReport() async {
        let sut = makeSUT()
        await sut.loadReport()
        #expect(sut.report != nil)

        reportRepo.deleteReportResult = .failure(APIError.serverError(status: 500))
        _ = await sut.deleteReport()

        #expect(sut.report != nil)
    }

    @Test func deleteReportSuccessCallsOnDelete() async {
        let tracker = CallTracker()
        let sut = makeSUT(onDelete: { tracker.called = true })

        let result = await sut.deleteReport()

        #expect(result)
        #expect(tracker.called)
    }

    @Test func deleteReportFailureDoesNotCallOnDelete() async {
        reportRepo.deleteReportResult = .failure(APIError.serverError(status: 500))
        let tracker = CallTracker()
        let sut = makeSUT(onDelete: { tracker.called = true })

        let result = await sut.deleteReport()

        #expect(!result)
        #expect(!tracker.called)
    }

    @Test func deleteReportWithNoOnDeleteCallback() async {
        let sut = makeSUT()

        let result = await sut.deleteReport()

        #expect(result)
    }

    @Test func deleteReportNetworkError() async {
        reportRepo.deleteReportResult = .failure(APIError.networkError(underlying: URLError(.notConnectedToInternet)))
        let sut = makeSUT()

        let result = await sut.deleteReport()

        #expect(!result)
        #expect(sut.error == "Failed to delete report")
    }

    @Test func deleteReportUnauthorizedError() async {
        reportRepo.deleteReportResult = .failure(APIError.unauthorized)
        let sut = makeSUT()

        let result = await sut.deleteReport()

        #expect(!result)
        #expect(sut.error == "Failed to delete report")
    }

    // MARK: - Show Delete Confirmation

    @Test func showDeleteConfirmationStartsFalse() {
        let sut = makeSUT()
        #expect(!sut.showDeleteConfirmation)
    }

    @Test func showDeleteConfirmationCanBeToggled() {
        let sut = makeSUT()
        sut.showDeleteConfirmation = true
        #expect(sut.showDeleteConfirmation)
    }

    // MARK: - Initial State

    @Test func initialState() {
        let sut = makeSUT()

        #expect(sut.report == nil)
        #expect(!sut.isLoading)
        #expect(sut.error == nil)
        #expect(sut.downloadURL == nil)
        #expect(!sut.showDeleteConfirmation)
        #expect(!sut.isDeleting)
        #expect(sut.extractionViewModel == nil)
    }
}
