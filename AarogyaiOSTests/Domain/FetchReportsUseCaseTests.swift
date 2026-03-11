import Foundation
import Testing
@testable import AarogyaiOS

@Suite("FetchReportsUseCase")
struct FetchReportsUseCaseTests {
    let reportRepo = MockReportRepository()

    var sut: FetchReportsUseCase {
        FetchReportsUseCase(reportRepository: reportRepo)
    }

    @Test func executeReturnsPaginatedResult() async throws {
        let result = try await sut.execute()
        #expect(result.items.count == 1)
        #expect(reportRepo.getReportsCallCount == 1)
    }

    @Test func executePassesParameters() async throws {
        _ = try await sut.execute(page: 2, pageSize: 10, type: .bloodTest, search: "test")
        #expect(reportRepo.getReportsCallCount == 1)
        #expect(reportRepo.lastGetReportsPage == 2)
    }

    @Test func executePropagatesError() async {
        reportRepo.getReportsResult = .failure(APIError.serverError(status: 500))
        await #expect(throws: APIError.self) {
            _ = try await sut.execute()
        }
    }

    @Test func executeWithCacheReturnsNetworkResult() async throws {
        let result = try await sut.executeWithCache()
        #expect(result.data.items.count == 1)
        #expect(!result.isCached)
        #expect(reportRepo.getReportsWithCacheCallCount == 1)
    }

    @Test func executeWithCacheReturnsCachedResult() async throws {
        let cached = CachedResult(
            data: PaginatedResult(items: [.stub, .stub], page: 1, pageSize: 20, totalCount: 2),
            source: CachedResult<PaginatedResult<Report>>.DataSource.cache,
            lastFetchedAt: Date.now.addingTimeInterval(-60)
        )
        reportRepo.getReportsWithCacheResult = .success(cached)

        let result = try await sut.executeWithCache()
        #expect(result.data.items.count == 2)
        #expect(result.isCached)
    }

    @Test func executeWithCachePropagatesError() async {
        reportRepo.getReportsWithCacheResult = .failure(APIError.serverError(status: 500))
        await #expect(throws: APIError.self) {
            _ = try await sut.executeWithCache()
        }
    }
}

@Suite("DeleteReportUseCase")
struct DeleteReportUseCaseTests {
    let reportRepo = MockReportRepository()

    var sut: DeleteReportUseCase {
        DeleteReportUseCase(reportRepository: reportRepo)
    }

    @Test func executeCallsRepository() async throws {
        try await sut.execute(reportId: "report-1")
        #expect(reportRepo.deleteReportCallCount == 1)
        #expect(reportRepo.lastDeletedReportId == "report-1")
    }

    @Test func executePropagatesError() async {
        reportRepo.deleteReportResult = .failure(APIError.serverError(status: 500))
        await #expect(throws: APIError.self) {
            try await sut.execute(reportId: "report-1")
        }
    }

    @Test func executePassesCorrectReportId() async throws {
        try await sut.execute(reportId: "custom-id-123")
        #expect(reportRepo.lastDeletedReportId == "custom-id-123")
    }
}

@Suite("UploadReportUseCase")
struct UploadReportUseCaseTests {
    let reportRepo = MockReportRepository()
    let fileUploader = MockFileUploader()

    var sut: UploadReportUseCase {
        UploadReportUseCase(reportRepository: reportRepo, uploadService: fileUploader)
    }

    @Test func executeUploadsAndCreatesReport() async throws {
        let input = UploadReportInput(
            fileData: Data("test".utf8),
            fileName: "report.pdf",
            contentType: "application/pdf",
            reportType: .bloodTest,
            title: "My Report",
            reportDate: nil,
            doctorName: nil,
            labName: nil,
            notes: nil
        )
        let report = try await sut.execute(input: input) { _ in }
        #expect(reportRepo.getUploadURLCallCount == 1)
        #expect(fileUploader.uploadCallCount == 1)
        #expect(reportRepo.createReportCallCount == 1)
        #expect(report.id == "report-1")
    }
}
