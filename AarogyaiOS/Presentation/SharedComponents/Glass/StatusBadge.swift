import SwiftUI

struct StatusBadge: View {
    let text: String
    let color: Color

    var body: some View {
        Text(text)
            .font(.caption.weight(.semibold))
            .padding(.horizontal, 10)
            .padding(.vertical, 4)
            .glassEffect(.regular.tint(color), in: .capsule)
    }
}

extension StatusBadge {
    init(reportStatus: ReportStatus) {
        self.text = reportStatus.rawValue.capitalized
        self.color = switch reportStatus {
        case .clean, .validated, .published:
            Color.Fallback.statusNormal
        case .infected:
            Color.Fallback.statusCritical
        case .processing, .extracting:
            Color.Fallback.statusWarning
        case .draft, .uploaded, .archived, .extracted, .extractionFailed:
            Color.Fallback.statusInfo
        }
    }

    init(extractionStatus: ExtractionStatus) {
        self.text = switch extractionStatus {
        case .pending: "Pending"
        case .inProgress: "Processing"
        case .completed: "Completed"
        case .failed: "Failed"
        }
        self.color = switch extractionStatus {
        case .completed:
            Color.Fallback.statusNormal
        case .failed:
            Color.Fallback.statusCritical
        case .inProgress:
            Color.Fallback.statusWarning
        case .pending:
            Color.Fallback.statusInfo
        }
    }

    init(accessGrantStatus: AccessGrantStatus) {
        self.text = accessGrantStatus.rawValue.capitalized
        self.color = switch accessGrantStatus {
        case .active:
            Color.Fallback.statusNormal
        case .expired, .revoked:
            Color.Fallback.statusCritical
        }
    }
}

#if DEBUG
#Preview {
    HStack(spacing: 8) {
        StatusBadge(reportStatus: .clean)
        StatusBadge(reportStatus: .infected)
        StatusBadge(reportStatus: .processing)
        StatusBadge(accessGrantStatus: .active)
    }
    .padding()
    .sereneBloomBackground()
}
#endif
