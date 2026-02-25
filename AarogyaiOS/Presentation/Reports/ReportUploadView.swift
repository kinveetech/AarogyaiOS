import SwiftUI
import UniformTypeIdentifiers

struct ReportUploadView: View {
    @State var viewModel: ReportUploadViewModel
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                stepIndicator

                ScrollView {
                    VStack(spacing: 24) {
                        switch viewModel.currentStep {
                        case .fileSelection:
                            fileSelectionStep
                        case .metadata:
                            metadataStep
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

    // MARK: - Step 1: File Selection

    @State private var showFilePicker = false

    private var fileSelectionStep: some View {
        VStack(spacing: 20) {
            Text("Select a file")
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

    // MARK: - Step 2: Metadata

    private var metadataStep: some View {
        VStack(spacing: 16) {
            Text("Report Details")
                .font(Typography.title)

            TextField("Title (optional)", text: $viewModel.title)
                .font(Typography.body)
                .padding(12)
                .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 12))

            Picker("Report Type", selection: $viewModel.reportType) {
                ForEach(ReportType.allCases, id: \.self) { type in
                    Text(type.rawValue.replacingOccurrences(of: "_", with: " ").capitalized)
                        .tag(type)
                }
            }
            .pickerStyle(.menu)

            DatePicker("Report Date", selection: $viewModel.reportDate, displayedComponents: .date)
                .font(Typography.body)

            TextField("Doctor Name (optional)", text: $viewModel.doctorName)
                .font(Typography.body)
                .padding(12)
                .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 12))

            TextField("Lab Name (optional)", text: $viewModel.labName)
                .font(Typography.body)
                .padding(12)
                .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 12))

            TextField("Notes (optional)", text: $viewModel.notes, axis: .vertical)
                .font(Typography.body)
                .lineLimit(3...6)
                .padding(12)
                .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 12))
        }
    }

    // MARK: - Step 3: Upload Progress

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
            if viewModel.currentStep != .fileSelection {
                SecondaryButton("Back", icon: "chevron.left") {
                    viewModel.previousStep()
                }
            }

            if viewModel.currentStep == .fileSelection {
                PrimaryButton("Continue", icon: "chevron.right") {
                    viewModel.nextStep()
                }
                .disabled(!viewModel.canProceedFromStep1 || viewModel.isFileTooLarge)
            } else if viewModel.currentStep == .metadata {
                PrimaryButton("Upload", icon: "arrow.up") {
                    viewModel.nextStep()
                }
            }
        }
        .padding(24)
    }
}
