import Foundation

struct DownloadReportUseCase: Sendable {
    private let reportRepository: any ReportRepository

    init(reportRepository: any ReportRepository) {
        self.reportRepository = reportRepository
    }

    func execute(reportId: String) async throws -> URL {
        try await reportRepository.getDownloadURL(reportId: reportId)
    }
}
