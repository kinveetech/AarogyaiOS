import Foundation

struct DeleteReportUseCase: Sendable {
    private let reportRepository: any ReportRepository

    init(reportRepository: any ReportRepository) {
        self.reportRepository = reportRepository
    }

    func execute(reportId: String) async throws {
        try await reportRepository.deleteReport(id: reportId)
    }
}
