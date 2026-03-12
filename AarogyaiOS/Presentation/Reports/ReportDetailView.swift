import SwiftUI

struct ReportDetailView: View {
    @State var viewModel: ReportDetailViewModel
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        Group {
            if viewModel.isLoading {
                LoadingView("Loading report...")
            } else if let report = viewModel.report {
                reportContent(report)
            } else {
                EmptyStateView(
                    icon: "exclamationmark.triangle",
                    title: "Report not found",
                    subtitle: viewModel.error ?? "The report could not be loaded"
                )
            }
        }
        .navigationTitle(viewModel.report?.title ?? "Report")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItemGroup(placement: .primaryAction) {
                Button {
                    Task { await viewModel.download() }
                } label: {
                    Image(systemName: "arrow.down.circle")
                }

                Button(role: .destructive) {
                    viewModel.showDeleteConfirmation = true
                } label: {
                    Image(systemName: "trash")
                }
            }
        }
        .confirmationDialog(
            "Delete Report",
            isPresented: $viewModel.showDeleteConfirmation,
            titleVisibility: .visible
        ) {
            Button("Delete", role: .destructive) {
                Task {
                    if await viewModel.deleteReport() {
                        dismiss()
                    }
                }
            }
        } message: {
            Text("This action cannot be undone.")
        }
        .overlay {
            if viewModel.isDeleting {
                ZStack {
                    Color.black.opacity(0.3)
                        .ignoresSafeArea()
                    ProgressView("Deleting...")
                        .padding(24)
                        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 16))
                }
            }
        }
        .allowsHitTesting(!viewModel.isDeleting)
        .task { await viewModel.loadReport() }
    }

    private func reportContent(_ report: Report) -> some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                reportHeader(report)
                if let extractionVM = viewModel.extractionViewModel {
                    ExtractionStatusView(viewModel: extractionVM)
                }
                if !report.parameters.isEmpty {
                    parametersSection(report.parameters)
                }
                metadataSection(report)
            }
            .padding(16)
        }
    }

    private func reportHeader(_ report: Report) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text(report.title)
                    .font(Typography.title)
                Spacer()
                StatusBadge(reportStatus: report.status)
            }

            Text(report.reportNumber)
                .font(Typography.data)
                .foregroundStyle(.secondary)

            if let highlight = report.highlightParameter {
                Text(highlight)
                    .font(Typography.data)
                    .foregroundStyle(Color.Fallback.brandPrimary)
                    .padding(12)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(Color.Fallback.bgSecondary, in: RoundedRectangle(cornerRadius: 12))
            }
        }
    }

    private func parametersSection(_ parameters: [ReportParameter]) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Parameters")
                .font(Typography.headline)

            ForEach(parameters) { param in
                ReportParameterRow(parameter: param)
            }
        }
    }

    private func metadataSection(_ report: Report) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Details")
                .font(Typography.headline)

            metadataRow("Type", value: report.reportType.displayName)
            if let doctor = report.doctorName {
                metadataRow("Doctor", value: doctor)
            }
            if let lab = report.labName {
                metadataRow("Lab", value: lab)
            }
            metadataRow("Uploaded", value: report.uploadedAt.formatted(date: .long, time: .shortened))
            if let fileSize = report.fileSizeBytes {
                metadataRow("File Size", value: ByteCountFormatter.string(fromByteCount: Int64(fileSize), countStyle: .file))
            }
        }
        .padding(16)
        .background(Color.Fallback.bgSecondary, in: RoundedRectangle(cornerRadius: 16))
    }

    private func metadataRow(_ label: String, value: String) -> some View {
        HStack {
            Text(label)
                .font(Typography.subheadline)
                .foregroundStyle(.secondary)
            Spacer()
            Text(value)
                .font(Typography.body)
        }
    }
}

struct ReportParameterRow: View {
    let parameter: ReportParameter

    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 2) {
                Text(parameter.name)
                    .font(Typography.subheadline)
                    .foregroundStyle(.secondary)
                if let range = parameter.referenceRange {
                    Text("Ref: \(range)")
                        .font(Typography.caption)
                        .foregroundStyle(.tertiary)
                }
            }

            Spacer()

            HStack(spacing: 4) {
                if let numeric = parameter.numericValue {
                    Text(String(format: "%.1f", numeric))
                        .font(Typography.data)
                } else if let text = parameter.textValue {
                    Text(text)
                        .font(Typography.data)
                }
                if let unit = parameter.unit {
                    Text(unit)
                        .font(Typography.caption)
                        .foregroundStyle(.secondary)
                }
            }
            .foregroundStyle(parameter.isAbnormal ? Color.Fallback.statusCritical : Color.Fallback.textPrimary)
        }
        .padding(12)
        .background(
            parameter.isAbnormal
                ? Color.Fallback.statusCritical.opacity(0.05)
                : Color.Fallback.bgSecondary,
            in: RoundedRectangle(cornerRadius: 10)
        )
    }
}
