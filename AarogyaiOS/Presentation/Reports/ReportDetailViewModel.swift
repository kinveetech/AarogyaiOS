import Foundation
import OSLog

@Observable
@MainActor
final class ReportDetailViewModel {
    var report: Report?
    var isLoading = false
    var error: String?
    var downloadURL: URL?
    var showDeleteConfirmation = false
    var isDeleting = false

    private let reportId: String
    private let fetchReportsUseCase: FetchReportsUseCase
    private let downloadReportUseCase: DownloadReportUseCase
    private let deleteReportUseCase: DeleteReportUseCase

    init(
        reportId: String,
        fetchReportsUseCase: FetchReportsUseCase,
        downloadReportUseCase: DownloadReportUseCase,
        deleteReportUseCase: DeleteReportUseCase
    ) {
        self.reportId = reportId
        self.fetchReportsUseCase = fetchReportsUseCase
        self.downloadReportUseCase = downloadReportUseCase
        self.deleteReportUseCase = deleteReportUseCase
    }

    func loadReport() async {
        isLoading = true
        error = nil

        do {
            let result = try await fetchReportsUseCase.execute(search: reportId)
            report = result.items.first
        } catch {
            self.error = "Failed to load report details"
            Logger.data.error("Load report detail failed: \(error)")
        }

        isLoading = false
    }

    func download() async {
        do {
            downloadURL = try await downloadReportUseCase.execute(reportId: reportId)
        } catch {
            self.error = "Failed to generate download link"
            Logger.data.error("Download URL failed: \(error)")
        }
    }

    func deleteReport() async -> Bool {
        isDeleting = true
        defer { isDeleting = false }

        do {
            try await deleteReportUseCase.execute(reportId: reportId)
            return true
        } catch {
            self.error = "Failed to delete report"
            Logger.data.error("Delete report failed: \(error)")
            return false
        }
    }
}
