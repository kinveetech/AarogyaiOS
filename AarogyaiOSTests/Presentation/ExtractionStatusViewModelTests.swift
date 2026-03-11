import Foundation
import Testing
@testable import AarogyaiOS

@Suite("ExtractionStatusViewModel")
@MainActor
struct ExtractionStatusViewModelTests {
    let reportRepo = MockReportRepository()

    func makeSUT(reportId: String = "report-1") -> ExtractionStatusViewModel {
        let useCase = ExtractionUseCase(reportRepository: reportRepo)
        return ExtractionStatusViewModel(reportId: reportId, extractionUseCase: useCase)
    }

    // MARK: - Load Status

    @Test func loadStatusSuccess() async {
        reportRepo.getExtractionStatusResult = .success(.stubCompleted)
        let sut = makeSUT()

        await sut.loadStatus()

        #expect(sut.extraction != nil)
        #expect(sut.extraction?.status == .completed)
        #expect(sut.error == nil)
        #expect(!sut.isLoading)
        #expect(reportRepo.getExtractionStatusCallCount == 1)
        #expect(reportRepo.lastExtractionReportId == "report-1")
    }

    @Test func loadStatusFailure() async {
        reportRepo.getExtractionStatusResult = .failure(APIError.serverError(status: 500))
        let sut = makeSUT()

        await sut.loadStatus()

        #expect(sut.extraction == nil)
        #expect(sut.error == "Failed to load extraction status")
        #expect(!sut.isLoading)
    }

    @Test func loadStatusPending() async {
        reportRepo.getExtractionStatusResult = .success(.stubPending)
        let sut = makeSUT()

        await sut.loadStatus()

        #expect(sut.extraction?.status == .pending)
        #expect(sut.extraction?.extractedParameterCount == 0)
    }

    @Test func loadStatusInProgress() async {
        reportRepo.getExtractionStatusResult = .success(.stubInProgress)
        let sut = makeSUT()

        await sut.loadStatus()

        #expect(sut.extraction?.status == .inProgress)
    }

    @Test func loadStatusFailed() async {
        reportRepo.getExtractionStatusResult = .success(.stubFailed)
        let sut = makeSUT()

        await sut.loadStatus()

        #expect(sut.extraction?.status == .failed)
        #expect(sut.extraction?.errorMessage == "OCR processing failed for this document")
        #expect(sut.extraction?.attemptCount == 2)
    }

    // MARK: - Trigger Extraction

    @Test func triggerExtractionSuccess() async {
        reportRepo.getExtractionStatusResult = .success(.stubPending)
        let sut = makeSUT()

        await sut.loadStatus()
        #expect(sut.canTriggerExtraction)

        reportRepo.getExtractionStatusResult = .success(.stubInProgress)
        await sut.triggerExtraction()

        #expect(sut.extraction?.status == .inProgress)
        #expect(sut.error == nil)
        #expect(!sut.isTriggering)
        #expect(reportRepo.triggerExtractionCallCount == 1)
        // loadStatus(1) + triggerExtraction reloads status(1) = 2 total
        #expect(reportRepo.getExtractionStatusCallCount == 2)
    }

    @Test func triggerExtractionFailure() async {
        reportRepo.getExtractionStatusResult = .success(.stubPending)
        let sut = makeSUT()

        await sut.loadStatus()

        reportRepo.triggerExtractionResult = .failure(APIError.serverError(status: 500))
        await sut.triggerExtraction()

        #expect(sut.error == "Failed to trigger extraction")
        #expect(!sut.isTriggering)
    }

    @Test func triggerExtractionFromFailedState() async {
        reportRepo.getExtractionStatusResult = .success(.stubFailed)
        let sut = makeSUT()

        await sut.loadStatus()
        #expect(sut.canTriggerExtraction)
        #expect(sut.triggerButtonTitle == "Re-extract")

        reportRepo.getExtractionStatusResult = .success(.stubInProgress)
        await sut.triggerExtraction()

        #expect(sut.extraction?.status == .inProgress)
        #expect(reportRepo.triggerExtractionCallCount == 1)
    }

    // MARK: - canTriggerExtraction

    @Test func canTriggerExtractionWhenNoExtraction() {
        let sut = makeSUT()
        #expect(sut.canTriggerExtraction)
    }

    @Test func canTriggerExtractionWhenPending() async {
        reportRepo.getExtractionStatusResult = .success(.stubPending)
        let sut = makeSUT()
        await sut.loadStatus()
        #expect(sut.canTriggerExtraction)
    }

    @Test func canTriggerExtractionWhenFailed() async {
        reportRepo.getExtractionStatusResult = .success(.stubFailed)
        let sut = makeSUT()
        await sut.loadStatus()
        #expect(sut.canTriggerExtraction)
    }

    @Test func cannotTriggerExtractionWhenCompleted() async {
        reportRepo.getExtractionStatusResult = .success(.stubCompleted)
        let sut = makeSUT()
        await sut.loadStatus()
        #expect(!sut.canTriggerExtraction)
    }

    @Test func cannotTriggerExtractionWhenInProgress() async {
        reportRepo.getExtractionStatusResult = .success(.stubInProgress)
        let sut = makeSUT()
        await sut.loadStatus()
        #expect(!sut.canTriggerExtraction)
    }

    // MARK: - triggerButtonTitle

    @Test func triggerButtonTitleExtractWhenNoExtraction() {
        let sut = makeSUT()
        #expect(sut.triggerButtonTitle == "Extract")
    }

    @Test func triggerButtonTitleExtractWhenPending() async {
        reportRepo.getExtractionStatusResult = .success(.stubPending)
        let sut = makeSUT()
        await sut.loadStatus()
        #expect(sut.triggerButtonTitle == "Extract")
    }

    @Test func triggerButtonTitleReExtractWhenFailed() async {
        reportRepo.getExtractionStatusResult = .success(.stubFailed)
        let sut = makeSUT()
        await sut.loadStatus()
        #expect(sut.triggerButtonTitle == "Re-extract")
    }

    // MARK: - confidenceText

    @Test func confidenceTextWhenCompleted() async {
        reportRepo.getExtractionStatusResult = .success(.stubCompleted)
        let sut = makeSUT()
        await sut.loadStatus()
        #expect(sut.confidenceText == "95%")
    }

    @Test func confidenceTextNilWhenPending() async {
        reportRepo.getExtractionStatusResult = .success(.stubPending)
        let sut = makeSUT()
        await sut.loadStatus()
        #expect(sut.confidenceText == nil)
    }

    @Test func confidenceTextNilWhenNoExtraction() {
        let sut = makeSUT()
        #expect(sut.confidenceText == nil)
    }

    // MARK: - Report ID Passed Correctly

    @Test func reportIdPassedToRepository() async {
        let sut = makeSUT(reportId: "custom-report-id")
        await sut.loadStatus()
        #expect(reportRepo.lastExtractionReportId == "custom-report-id")
    }

    @Test func triggerPassesReportIdToRepository() async {
        reportRepo.getExtractionStatusResult = .success(.stubPending)
        let sut = makeSUT(reportId: "trigger-report-id")
        await sut.loadStatus()
        await sut.triggerExtraction()
        #expect(reportRepo.lastExtractionReportId == "trigger-report-id")
    }

    // MARK: - Error Cleared on Retry

    @Test func errorClearedOnRetryLoadStatus() async {
        reportRepo.getExtractionStatusResult = .failure(APIError.serverError(status: 500))
        let sut = makeSUT()

        await sut.loadStatus()
        #expect(sut.error != nil)

        reportRepo.getExtractionStatusResult = .success(.stubCompleted)
        await sut.loadStatus()
        #expect(sut.error == nil)
        #expect(sut.extraction?.status == .completed)
    }

    @Test func errorClearedOnRetryTrigger() async {
        reportRepo.getExtractionStatusResult = .success(.stubPending)
        let sut = makeSUT()
        await sut.loadStatus()

        reportRepo.triggerExtractionResult = .failure(APIError.serverError(status: 500))
        await sut.triggerExtraction()
        #expect(sut.error != nil)

        reportRepo.triggerExtractionResult = .success(())
        reportRepo.getExtractionStatusResult = .success(.stubInProgress)
        await sut.triggerExtraction()
        #expect(sut.error == nil)
    }
}
