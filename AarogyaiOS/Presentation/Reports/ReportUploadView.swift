import SwiftUI
import UniformTypeIdentifiers

struct ReportUploadView: View {
    @State var viewModel: ReportUploadViewModel
    let onUploadComplete: (() -> Void)?
    @Environment(\.dismiss) private var dismiss

    init(viewModel: ReportUploadViewModel, onUploadComplete: (() -> Void)? = nil) {
        self.viewModel = viewModel
        self.onUploadComplete = onUploadComplete
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                stepIndicator

                ScrollView {
                    VStack(spacing: 24) {
                        switch viewModel.currentStep {
                        case .fileSelection:
                            fileSelectionStep
                        case .uploading:
                            uploadingStep
                        }
                    }
                    .padding(24)
                }

                if viewModel.currentStep != .uploading {
                    navigationButtons
                }
            }
            .sereneBloomBackground()
            .navigationTitle("Upload Report")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
            }
        }
    }

    // MARK: - Step Indicator

    private var stepIndicator: some View {
        HStack(spacing: 8) {
            ForEach(ReportUploadViewModel.UploadStep.allCases, id: \.rawValue) { step in
                Capsule()
                    .fill(step.rawValue <= viewModel.currentStep.rawValue
                          ? Color.Fallback.brandPrimary
                          : Color.Fallback.borderDefault)
                    .frame(height: 4)
            }
        }
        .padding(.horizontal, 24)
        .padding(.vertical, 8)
    }

    // MARK: - Step 1: File Selection + Report Type

    @State private var showFilePicker = false

    private var fileSelectionStep: some View {
        VStack(spacing: 20) {
            Text("Upload Report")
                .font(Typography.title)

            Button {
                showFilePicker = true
            } label: {
                VStack(spacing: 12) {
                    Image(systemName: "doc.badge.plus")
                        .font(.system(size: 48))
                        .foregroundStyle(Color.Fallback.brandPrimary)

                    if viewModel.fileData != nil {
                        Text(viewModel.fileName)
                            .font(Typography.headline)
                        Text(viewModel.fileSizeText)
                            .font(Typography.caption)
                            .foregroundStyle(.secondary)
                    } else {
                        Text("Tap to select PDF or image")
                            .font(Typography.callout)
                            .foregroundStyle(.secondary)
                    }
                }
                .frame(maxWidth: .infinity)
                .padding(32)
                .background(
                    RoundedRectangle(cornerRadius: 16)
                        .strokeBorder(
                            viewModel.fileData != nil
                                ? Color.Fallback.brandPrimary
                                : Color.Fallback.borderDefault,
                            style: StrokeStyle(lineWidth: 2, dash: [8])
                        )
                )
            }
            .buttonStyle(.plain)
            .fileImporter(
                isPresented: $showFilePicker,
                allowedContentTypes: [.pdf, .jpeg, .png],
                allowsMultipleSelection: false
            ) { result in
                handleFileSelection(result)
            }

            if viewModel.isFileTooLarge {
                Text("File exceeds maximum size of 50 MB")
                    .font(Typography.caption)
                    .foregroundStyle(Color.Fallback.statusCritical)
            }

            if viewModel.fileData != nil {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Report Type")
                        .font(Typography.callout)
                        .foregroundStyle(.secondary)

                    Picker("Report Type", selection: $viewModel.reportType) {
                        ForEach(ReportType.allCases, id: \.self) { type in
                            Text(type.displayName)
                                .tag(type)
                        }
                    }
                    .pickerStyle(.menu)
                    .frame(maxWidth: .infinity, alignment: .leading)
                }
            }
        }
    }

    private func handleFileSelection(_ result: Result<[URL], Error>) {
        guard case .success(let urls) = result, let url = urls.first else { return }
        guard url.startAccessingSecurityScopedResource() else { return }
        defer { url.stopAccessingSecurityScopedResource() }

        do {
            let data = try Data(contentsOf: url)
            let contentType = url.pathExtension == "pdf" ? "application/pdf" : "image/jpeg"
            viewModel.setFile(data: data, name: url.lastPathComponent, contentType: contentType)
        } catch {
            // File read error handled silently
        }
    }

    // MARK: - Step 2: Upload Progress

    private var uploadingStep: some View {
        VStack(spacing: 24) {
            switch viewModel.uploadState {
            case .idle:
                ProgressView()
            case .uploading(let progress):
                uploadProgress(progress)
            case .success(let report):
                uploadSuccess(report)
            case .failed(let message):
                uploadFailed(message)
            }
        }
    }

    private func uploadProgress(_ progress: Double) -> some View {
        VStack(spacing: 16) {
            Image(systemName: "arrow.up.doc")
                .font(.system(size: 48))
                .foregroundStyle(Color.Fallback.brandPrimary)

            Text("Uploading...")
                .font(Typography.title)

            ProgressView(value: progress)
                .tint(Color.Fallback.brandPrimary)

            Text("\(Int(progress * 100))%")
                .font(Typography.data)
                .foregroundStyle(.secondary)

            Text(viewModel.fileName)
                .font(Typography.caption)
                .foregroundStyle(.tertiary)
        }
    }

    private func uploadSuccess(_ report: Report) -> some View {
        VStack(spacing: 16) {
            Image(systemName: "checkmark.circle.fill")
                .font(.system(size: 64))
                .foregroundStyle(Color.Fallback.statusNormal)

            Text("Upload Complete")
                .font(Typography.title)

            Text(report.title)
                .font(Typography.callout)
                .foregroundStyle(.secondary)

            PrimaryButton("Done") {
                onUploadComplete?()
                dismiss()
            }
        }
    }

    private func uploadFailed(_ message: String) -> some View {
        VStack(spacing: 16) {
            Image(systemName: "exclamationmark.triangle.fill")
                .font(.system(size: 64))
                .foregroundStyle(Color.Fallback.statusCritical)

            Text("Upload Failed")
                .font(Typography.title)

            Text(message)
                .font(Typography.callout)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)

            PrimaryButton("Retry", icon: "arrow.clockwise") {
                viewModel.retry()
            }
        }
    }

    // MARK: - Navigation

    private var navigationButtons: some View {
        HStack(spacing: 12) {
            if viewModel.currentStep == .fileSelection {
                PrimaryButton("Upload", icon: "arrow.up") {
                    viewModel.nextStep()
                }
                .disabled(!viewModel.canProceedFromStep1 || viewModel.isFileTooLarge)
            }
        }
        .padding(24)
    }
}
