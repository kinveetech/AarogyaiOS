import Foundation
import Testing
@testable import AarogyaiOS

@Suite("DownloadReportUseCase")
struct DownloadReportUseCaseTests {
    @Test("Simple execute returns download URL from repository")
    @MainActor
    func simpleExecuteReturnsURL() async throws {
        let repo = MockReportRepository()
        let expectedURL = URL(string: "https://cdn.example.com/report.pdf")!
        repo.getDownloadURLResult = .success(expectedURL)
        let useCase = DownloadReportUseCase(reportRepository: repo)

        let url: URL = try await useCase.execute(reportId: "report-1")
        #expect(url == expectedURL)
        #expect(repo.getDownloadURLCallCount == 1)
    }

    @Test("Simple execute propagates repository errors")
    @MainActor
    func simpleExecutePropagatesError() async {
        let repo = MockReportRepository()
        repo.getDownloadURLResult = .failure(APIError.notFound)
        let useCase = DownloadReportUseCase(reportRepository: repo)

        await #expect(throws: APIError.self) {
            let _: URL = try await useCase.execute(reportId: "report-1")
        }
    }

    @Test("Verified execute falls back to standard download on verified endpoint failure")
    @MainActor
    func verifiedExecuteFallsBackOnFailure() async throws {
        let repo = MockReportRepository()
        repo.getVerifiedDownloadURLResult = .failure(APIError.notFound)
        let expectedURL = URL(string: "https://cdn.example.com/fallback.pdf")!
        repo.getDownloadURLResult = .success(expectedURL)
        let useCase = DownloadReportUseCase(reportRepository: repo)

        let result = try await useCase.execute(reportId: "report-1", expectedChecksum: nil)
        #expect(result.fileURL == expectedURL)
        #expect(result.isVerified == false)
        #expect(result.isChecksumValid == false)
        #expect(repo.getVerifiedDownloadURLCallCount == 1)
        #expect(repo.getDownloadURLCallCount == 1)
    }
}
