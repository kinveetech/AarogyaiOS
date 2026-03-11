import Foundation
import Testing
@testable import AarogyaiOS

@Suite("ReportDetailViewModel")
@MainActor
struct ReportDetailViewModelTests {
    let reportRepo = MockReportRepository()

    func makeSUT(reportId: String = "report-1") -> ReportDetailViewModel {
        let fetchUseCase = FetchReportsUseCase(reportRepository: reportRepo)
        let downloadUseCase = DownloadReportUseCase(reportRepository: reportRepo)
        let deleteUseCase = DeleteReportUseCase(reportRepository: reportRepo)
        let extractionUseCase = ExtractionUseCase(reportRepository: reportRepo)
        return ReportDetailViewModel(
            reportId: reportId,
            fetchReportsUseCase: fetchUseCase,
            downloadReportUseCase: downloadUseCase,
            deleteReportUseCase: deleteUseCase,
            extractionUseCase: extractionUseCase
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
    }

    @Test func deleteReportFailure() async {
        reportRepo.deleteReportResult = .failure(APIError.serverError(status: 500))
        let sut = makeSUT()

        let result = await sut.deleteReport()

        #expect(!result)
        #expect(sut.error == "Failed to delete report")
        #expect(!sut.isDeleting)
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
