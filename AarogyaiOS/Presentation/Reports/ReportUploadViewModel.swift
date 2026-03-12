import Foundation
import OSLog

@Observable
@MainActor
final class ReportUploadViewModel {
    enum UploadStep: Int, CaseIterable {
        case fileSelection = 1
        case uploading = 2
    }

    enum UploadState {
        case idle
        case uploading(progress: Double)
        case success(Report)
        case failed(String)
    }

    // Navigation
    var currentStep: UploadStep = .fileSelection

    // Step 1: File Selection + Report Type
    var fileData: Data?
    var fileName: String = ""
    var fileContentType: String = "application/pdf"
    var reportType: ReportType = .bloodTest

    // Step 2: Upload
    var uploadState: UploadState = .idle

    private let uploadReportUseCase: UploadReportUseCase

    init(uploadReportUseCase: UploadReportUseCase) {
        self.uploadReportUseCase = uploadReportUseCase
    }

    var canProceedFromStep1: Bool {
        fileData != nil && !fileName.isEmpty
    }

    var fileSizeText: String {
        guard let data = fileData else { return "" }
        return ByteCountFormatter.string(fromByteCount: Int64(data.count), countStyle: .file)
    }

    var isFileTooLarge: Bool {
        guard let data = fileData else { return false }
        return data.count > Constants.Upload.maxFileSizeBytes
    }

    func setFile(data: Data, name: String, contentType: String) {
        fileData = data
        fileName = name
        fileContentType = contentType
    }

    func nextStep() {
        switch currentStep {
        case .fileSelection:
            currentStep = .uploading
            Task { await startUpload() }
        case .uploading:
            break
        }
    }

    func previousStep() {
        switch currentStep {
        case .fileSelection:
            break
        case .uploading:
            break
        }
    }

    private func startUpload() async {
        guard let fileData else { return }

        uploadState = .uploading(progress: 0)

        do {
            let input = UploadReportInput(
                fileData: fileData,
                fileName: fileName,
                contentType: fileContentType,
                reportType: reportType
            )

            let report = try await uploadReportUseCase.execute(input: input) { [weak self] progress in
                Task { @MainActor in
                    self?.uploadState = .uploading(progress: progress)
                }
            }

            uploadState = .success(report)
        } catch {
            uploadState = .failed("Upload failed. Please try again.")
            Logger.upload.error("Report upload failed: \(error)")
        }
    }

    func retry() {
        Task { await startUpload() }
    }
}
