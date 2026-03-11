import SwiftUI

struct ExtractionStatusView: View {
    @State var viewModel: ExtractionStatusViewModel

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            headerRow

            if viewModel.isLoading {
                ProgressView()
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding(.vertical, 8)
            } else if let extraction = viewModel.extraction {
                extractionDetails(extraction)
            } else if let error = viewModel.error {
                Text(error)
                    .font(Typography.caption)
                    .foregroundStyle(Color.Fallback.statusCritical)
            }

            if viewModel.canTriggerExtraction {
                triggerButton
            }
        }
        .padding(16)
        .background(Color.Fallback.bgSecondary, in: RoundedRectangle(cornerRadius: 16))
        .task { await viewModel.loadStatus() }
    }

    private var headerRow: some View {
        HStack {
            Text("Extraction")
                .font(Typography.headline)
            Spacer()
            if let extraction = viewModel.extraction {
                StatusBadge(extractionStatus: extraction.status)
            }
        }
    }

    private func extractionDetails(_ extraction: ReportExtraction) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            if extraction.extractedParameterCount > 0 {
                detailRow(
                    "Parameters",
                    value: "\(extraction.extractedParameterCount)"
                )
            }

            if let confidence = viewModel.confidenceText {
                detailRow("Confidence", value: confidence)
            }

            if let method = extraction.extractionMethod {
                detailRow("Method", value: method.uppercased())
            }

            if let model = extraction.structuringModel {
                detailRow("Model", value: model)
            }

            if let pageCount = extraction.pageCount {
                detailRow("Pages", value: "\(pageCount)")
            }

            if let extractedAt = extraction.extractedAt {
                detailRow(
                    "Extracted",
                    value: extractedAt.formatted(date: .abbreviated, time: .shortened)
                )
            }

            if extraction.status == .failed, let errorMessage = extraction.errorMessage {
                Text(errorMessage)
                    .font(Typography.caption)
                    .foregroundStyle(Color.Fallback.statusCritical)
                    .padding(.top, 4)
            }
        }
    }

    private func detailRow(_ label: String, value: String) -> some View {
        HStack {
            Text(label)
                .font(Typography.subheadline)
                .foregroundStyle(.secondary)
            Spacer()
            Text(value)
                .font(Typography.data)
        }
    }

    private var triggerButton: some View {
        Button {
            Task { await viewModel.triggerExtraction() }
        } label: {
            HStack(spacing: 8) {
                if viewModel.isTriggering {
                    ProgressView()
                        .controlSize(.small)
                } else {
                    Image(systemName: "wand.and.stars")
                }
                Text(viewModel.triggerButtonTitle)
                    .font(Typography.headline)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 12)
        }
        .buttonStyle(.glass)
        .disabled(viewModel.isTriggering)
        .padding(.top, 4)
    }
}

#if DEBUG
#Preview("Completed") {
    ExtractionStatusView(
        viewModel: ExtractionStatusViewModel(
            reportId: "rpt-1",
            extractionUseCase: ExtractionUseCase(
                reportRepository: PreviewExtractionRepo(status: .completed)
            )
        )
    )
    .padding()
    .sereneBloomBackground()
}

#Preview("Failed") {
    ExtractionStatusView(
        viewModel: ExtractionStatusViewModel(
            reportId: "rpt-1",
            extractionUseCase: ExtractionUseCase(
                reportRepository: PreviewExtractionRepo(status: .failed)
            )
        )
    )
    .padding()
    .sereneBloomBackground()
}

#Preview("Pending") {
    ExtractionStatusView(
        viewModel: ExtractionStatusViewModel(
            reportId: "rpt-1",
            extractionUseCase: ExtractionUseCase(
                reportRepository: PreviewExtractionRepo(status: .pending)
            )
        )
    )
    .padding()
    .sereneBloomBackground()
}

private final class PreviewExtractionRepo: ReportRepository, @unchecked Sendable {
    let status: ExtractionStatus

    init(status: ExtractionStatus) {
        self.status = status
    }

    // swiftlint:disable force_unwrapping line_length
    func getReports(page: Int, pageSize: Int, type: ReportType?, status: ReportStatus?, search: String?) async throws -> PaginatedResult<Report> {
        PaginatedResult(items: [], page: 1, pageSize: 20, totalCount: 0)
    }
    func getReport(id: String) async throws -> Report { PreviewData.report }
    func createReport(request: CreateReportInput) async throws -> Report { PreviewData.report }
    func deleteReport(id: String) async throws {}
    func getUploadURL(fileName: String, contentType: String) async throws -> PresignedUpload {
        PresignedUpload(uploadURL: URL(string: "https://example.com")!, fileStorageKey: "key")
    }
    func getDownloadURL(reportId: String) async throws -> URL { URL(string: "https://example.com")! }
    func getVerifiedDownloadURL(reportId: String) async throws -> VerifiedDownload {
        VerifiedDownload(downloadURL: URL(string: "https://example.com")!, checksumSha256: nil, isServerVerified: true)
    }
    // swiftlint:enable force_unwrapping line_length
    func getExtractionStatus(reportId: String) async throws -> ReportExtraction {
        ReportExtraction(
            status: status,
            extractionMethod: status == .completed ? "ai" : nil,
            structuringModel: status == .completed ? "gpt-4" : nil,
            extractedParameterCount: status == .completed ? 12 : 0,
            overallConfidence: status == .completed ? 0.95 : nil,
            pageCount: status == .completed ? 2 : nil,
            extractedAt: status == .completed ? .now : nil,
            errorMessage: status == .failed ? "OCR processing failed" : nil,
            attemptCount: status == .failed ? 2 : (status == .completed ? 1 : 0)
        )
    }
    func triggerExtraction(reportId: String) async throws {}
}
#endif
