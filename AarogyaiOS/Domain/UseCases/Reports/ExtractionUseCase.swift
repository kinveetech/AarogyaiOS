import Foundation

struct ExtractionUseCase: Sendable {
    private let reportRepository: any ReportRepository

    init(reportRepository: any ReportRepository) {
        self.reportRepository = reportRepository
    }

    func getStatus(reportId: String) async throws -> ReportExtraction {
        try await reportRepository.getExtractionStatus(reportId: reportId)
    }

    func trigger(reportId: String) async throws {
        try await reportRepository.triggerExtraction(reportId: reportId)
    }
}
