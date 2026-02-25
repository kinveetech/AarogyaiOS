import SwiftUI

struct ReportCard: View {
    let report: Report

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                reportTypeIcon
                VStack(alignment: .leading, spacing: 2) {
                    Text(report.title)
                        .font(Typography.headline)
                        .lineLimit(1)
                    Text(report.reportNumber)
                        .font(Typography.dataSmall)
                        .foregroundStyle(.secondary)
                }
                Spacer()
                StatusBadge(reportStatus: report.status)
            }

            if let highlight = report.highlightParameter {
                Text(highlight)
                    .font(Typography.data)
                    .foregroundStyle(Color.Fallback.brandPrimary)
                    .lineLimit(1)
            }

            HStack {
                if let labName = report.labName {
                    Label(labName, systemImage: "building.2")
                        .font(Typography.caption)
                        .foregroundStyle(.secondary)
                }
                Spacer()
                Text(report.uploadedAt.formatted(date: .abbreviated, time: .omitted))
                    .font(Typography.caption)
                    .foregroundStyle(.tertiary)
            }
        }
        .padding(16)
        .background(Color.Fallback.bgSecondary, in: RoundedRectangle(cornerRadius: 16))
    }

    private var reportTypeIcon: some View {
        Image(systemName: iconName)
            .font(.title3)
            .foregroundStyle(Color.Fallback.brandPrimary)
            .frame(width: 40, height: 40)
            .background(
                Color.Fallback.brandPrimaryLight.opacity(0.15),
                in: Circle()
            )
    }

    private var iconName: String {
        switch report.reportType {
        case .bloodTest: "drop.fill"
        case .urineTest: "flask.fill"
        case .radiology: "rays"
        case .cardiology: "heart.fill"
        case .other: "doc.text.fill"
        }
    }
}

#if DEBUG
#Preview {
    VStack(spacing: 12) {
        ReportCard(report: PreviewData.report)
        ReportCard(report: PreviewData.reports[1])
    }
    .padding()
    .sereneBloomBackground()
}
#endif
