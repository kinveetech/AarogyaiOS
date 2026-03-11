import SwiftUI

struct EmergencyAccessAuditView: View {
    @State var viewModel: EmergencyAccessAuditViewModel

    var body: some View {
        Group {
            if viewModel.isLoading && viewModel.entries.isEmpty {
                LoadingView("Loading audit trail...")
            } else if viewModel.isEmpty {
                EmptyStateView(
                    icon: "shield.lefthalf.filled",
                    title: "No audit entries",
                    subtitle: "Emergency access activity for your records will appear here"
                )
            } else {
                auditList
            }
        }
        .navigationTitle("Access Audit Trail")
        .refreshable { await viewModel.loadAuditTrail() }
        .task { await viewModel.loadAuditTrail() }
    }

    private var auditList: some View {
        List {
            ForEach(viewModel.entries) { entry in
                AuditEntryRow(
                    entry: entry,
                    displayAction: viewModel.displayAction(for: entry),
                    displayRole: viewModel.displayRole(for: entry),
                    iconName: viewModel.actionIconName(for: entry),
                    actionColor: viewModel.actionColor(for: entry)
                )
            }

            if viewModel.hasMorePages {
                Section {
                    HStack {
                        Spacer()
                        ProgressView()
                            .task { await viewModel.loadNextPage() }
                        Spacer()
                    }
                }
            }
        }
    }
}

// MARK: - Audit Entry Row

private struct AuditEntryRow: View {
    let entry: EmergencyAccessAuditEntry
    let displayAction: String
    let displayRole: String?
    let iconName: String
    let actionColor: AuditActionColor

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            actionIcon

            VStack(alignment: .leading, spacing: 4) {
                Text(displayAction)
                    .font(Typography.headline)

                if let displayRole {
                    Text(displayRole)
                        .font(Typography.caption)
                        .foregroundStyle(.secondary)
                }

                Text(entry.resourceType)
                    .font(Typography.caption)
                    .foregroundStyle(.tertiary)

                if let duration = entry.metadata["durationHours"] {
                    Text("Duration: \(duration)h")
                        .font(Typography.dataSmall)
                        .foregroundStyle(.secondary)
                }

                Text(entry.occurredAt.formatted(date: .abbreviated, time: .shortened))
                    .font(Typography.dataSmall)
                    .foregroundStyle(.tertiary)
            }

            Spacer()
        }
        .padding(.vertical, 4)
    }

    private var actionIcon: some View {
        Image(systemName: iconName)
            .font(.title3)
            .foregroundStyle(iconColor)
            .frame(width: 32)
    }

    private var iconColor: Color {
        switch actionColor {
        case .granted:
            .green
        case .revoked:
            .red
        case .requested:
            .orange
        case .viewed:
            Color.Fallback.brandPrimary
        case .neutral:
            .secondary
        }
    }
}

// MARK: - Preview

#if DEBUG
#Preview {
    NavigationStack {
        EmergencyAccessAuditView(
            viewModel: EmergencyAccessAuditViewModel(
                fetchAuditUseCase: FetchEmergencyAccessAuditUseCase(
                    emergencyAccessRepository: PreviewEmergencyAccessRepository()
                )
            )
        )
    }
    .sereneBloomBackground()
}

private struct PreviewEmergencyAccessRepository: EmergencyAccessRepository {
    func getAuditTrail(page: Int, pageSize: Int) async throws -> PaginatedResult<EmergencyAccessAuditEntry> {
        PaginatedResult(items: PreviewData.emergencyAccessAuditEntries, page: 1, pageSize: 20, totalCount: 3)
    }
}
#endif
