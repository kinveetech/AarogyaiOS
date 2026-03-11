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
    var extractionViewModel: ExtractionStatusViewModel?

    private let reportId: String
    private let fetchReportsUseCase: FetchReportsUseCase
    private let downloadReportUseCase: DownloadReportUseCase
    private let deleteReportUseCase: DeleteReportUseCase
    private let extractionUseCase: ExtractionUseCase
    private let onDelete: (@Sendable () -> Void)?

    init(
        reportId: String,
        fetchReportsUseCase: FetchReportsUseCase,
        downloadReportUseCase: DownloadReportUseCase,
        deleteReportUseCase: DeleteReportUseCase,
        extractionUseCase: ExtractionUseCase,
        onDelete: (@Sendable () -> Void)? = nil
    ) {
        self.reportId = reportId
        self.fetchReportsUseCase = fetchReportsUseCase
        self.downloadReportUseCase = downloadReportUseCase
        self.deleteReportUseCase = deleteReportUseCase
        self.extractionUseCase = extractionUseCase
        self.onDelete = onDelete
    }

    func loadReport() async {
        isLoading = true
        error = nil

        do {
            let result = try await fetchReportsUseCase.execute(search: reportId)
            report = result.items.first
            if report != nil {
                extractionViewModel = ExtractionStatusViewModel(
                    reportId: reportId,
                    extractionUseCase: extractionUseCase
                )
            }
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
            onDelete?()
            return true
        } catch {
            self.error = "Failed to delete report"
            Logger.data.error("Delete report failed: \(error)")
            return false
        }
    }
}
