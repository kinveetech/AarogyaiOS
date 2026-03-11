import Foundation
import Testing
@testable import AarogyaiOS

@Suite("ExtractionUseCase")
@MainActor
struct ExtractionUseCaseTests {
    let reportRepo = MockReportRepository()

    func makeSUT() -> ExtractionUseCase {
        ExtractionUseCase(reportRepository: reportRepo)
    }

    // MARK: - getStatus

    @Test func getStatusReturnsExtraction() async throws {
        reportRepo.getExtractionStatusResult = .success(.stubCompleted)
        let sut = makeSUT()

        let result = try await sut.getStatus(reportId: "report-1")

        #expect(result.status == .completed)
        #expect(result.extractedParameterCount == 12)
        #expect(result.overallConfidence == 0.95)
        #expect(result.extractionMethod == "ai")
        #expect(result.structuringModel == "gpt-4")
        #expect(result.attemptCount == 1)
        #expect(reportRepo.getExtractionStatusCallCount == 1)
        #expect(reportRepo.lastExtractionReportId == "report-1")
    }

    @Test func getStatusPropagatesError() async {
        reportRepo.getExtractionStatusResult = .failure(APIError.notFound)
        let sut = makeSUT()

        do {
            _ = try await sut.getStatus(reportId: "invalid")
            Issue.record("Expected error to be thrown")
        } catch {
            #expect(error is APIError)
        }
    }

    @Test func getStatusPassesCorrectReportId() async throws {
        let sut = makeSUT()
        _ = try await sut.getStatus(reportId: "my-report-id")
        #expect(reportRepo.lastExtractionReportId == "my-report-id")
    }

    // MARK: - trigger

    @Test func triggerCallsRepository() async throws {
        let sut = makeSUT()

        try await sut.trigger(reportId: "report-1")

        #expect(reportRepo.triggerExtractionCallCount == 1)
        #expect(reportRepo.lastExtractionReportId == "report-1")
    }

    @Test func triggerPropagatesError() async {
        reportRepo.triggerExtractionResult = .failure(APIError.serverError(status: 500))
        let sut = makeSUT()

        do {
            try await sut.trigger(reportId: "report-1")
            Issue.record("Expected error to be thrown")
        } catch {
            #expect(error is APIError)
        }
    }

    @Test func triggerPassesCorrectReportId() async throws {
        let sut = makeSUT()
        try await sut.trigger(reportId: "another-report")
        #expect(reportRepo.lastExtractionReportId == "another-report")
    }
}
