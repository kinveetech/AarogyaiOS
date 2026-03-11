import Foundation
import OSLog

@Observable
@MainActor
final class ExtractionStatusViewModel {
    var extraction: ReportExtraction?
    var isLoading = false
    var isTriggering = false
    var error: String?

    private let reportId: String
    private let extractionUseCase: ExtractionUseCase

    init(reportId: String, extractionUseCase: ExtractionUseCase) {
        self.reportId = reportId
        self.extractionUseCase = extractionUseCase
    }

    var canTriggerExtraction: Bool {
        guard !isTriggering else { return false }
        guard let extraction else { return true }
        return extraction.status == .pending || extraction.status == .failed
    }

    var triggerButtonTitle: String {
        guard let extraction else { return "Extract" }
        return extraction.attemptCount > 0 && extraction.status == .failed
            ? "Re-extract"
            : "Extract"
    }

    var confidenceText: String? {
        guard let confidence = extraction?.overallConfidence else { return nil }
        return "\(Int(confidence * 100))%"
    }

    func loadStatus() async {
        isLoading = true
        error = nil

        do {
            extraction = try await extractionUseCase.getStatus(reportId: reportId)
        } catch {
            self.error = "Failed to load extraction status"
            Logger.data.error("Load extraction status failed: \(error)")
        }

        isLoading = false
    }

    func triggerExtraction() async {
        guard canTriggerExtraction else { return }

        isTriggering = true
        error = nil

        do {
            try await extractionUseCase.trigger(reportId: reportId)
            // Reload status after triggering
            extraction = try await extractionUseCase.getStatus(reportId: reportId)
        } catch {
            self.error = "Failed to trigger extraction"
            Logger.data.error("Trigger extraction failed: \(error)")
        }

        isTriggering = false
    }
}
