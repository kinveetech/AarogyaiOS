import SwiftUI

struct AccessGrantsView: View {
    @State var viewModel: AccessGrantsViewModel

    var body: some View {
        Group {
            if viewModel.isLoading && viewModel.grantedGrants.isEmpty && viewModel.receivedGrants.isEmpty {
                LoadingView("Loading access grants...")
            } else {
                grantContent
            }
        }
        .navigationTitle("Access Grants")
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button {
                    viewModel.showCreateGrant = true
                } label: {
                    Image(systemName: "plus")
                }
            }
        }
        .refreshable { await viewModel.loadGrants() }
        .task { await viewModel.loadGrants() }
        .sheet(isPresented: $viewModel.showCreateGrant) {
            Task { await viewModel.onGrantCreated() }
        } content: {
            CreateAccessGrantView(
                createUseCase: viewModel.createGrantUseCase
            )
        }
    }

    @ViewBuilder
    private var grantContent: some View {
        if viewModel.showsReceivedSection {
            segmentedGrantsView
        } else {
            patientGrantsView
        }
    }

    // MARK: - Doctor View (Segmented)

    private var segmentedGrantsView: some View {
        VStack(spacing: 0) {
            Picker("Section", selection: $viewModel.selectedSection) {
                ForEach(GrantSection.allCases) { section in
                    Text(section.title).tag(section)
                }
            }
            .pickerStyle(.segmented)
            .padding(.horizontal)
            .padding(.vertical, 8)

            if viewModel.isActiveListEmpty {
                emptyStateForSection(viewModel.selectedSection)
            } else {
                List {
                    ForEach(viewModel.activeGrants) { grant in
                        grantRow(for: grant)
                    }
                }
            }
        }
    }

    // MARK: - Patient View

    private var patientGrantsView: some View {
        Group {
            if viewModel.grantedGrants.isEmpty {
                EmptyStateView(
                    icon: "person.2",
                    title: "No access grants",
                    subtitle: "Grant doctors access to your medical reports",
                    actionTitle: "Grant Access"
                ) {
                    viewModel.showCreateGrant = true
                }
            } else {
                List {
                    Section("Granted by You") {
                        ForEach(viewModel.grantedGrants) { grant in
                            AccessGrantRow(grant: grant, variant: .given) {
                                Task { await viewModel.revokeGrant(grant) }
                            }
                        }
                    }
                }
            }
        }
    }

    // MARK: - Helpers

    @ViewBuilder
    private func grantRow(for grant: AccessGrant) -> some View {
        switch viewModel.selectedSection {
        case .given:
            AccessGrantRow(grant: grant, variant: .given) {
                Task { await viewModel.revokeGrant(grant) }
            }
        case .received:
            AccessGrantRow(grant: grant, variant: .received, revokeAction: nil)
        }
    }

    @ViewBuilder
    private func emptyStateForSection(_ section: GrantSection) -> some View {
        switch section {
        case .given:
            EmptyStateView(
                icon: "person.2",
                title: "No given grants",
                subtitle: "Grant doctors access to your medical reports",
                actionTitle: "Grant Access"
            ) {
                viewModel.showCreateGrant = true
            }
        case .received:
            EmptyStateView(
                icon: "person.crop.rectangle.badge.plus",
                title: "No received grants",
                subtitle: "Patients who grant you access to their reports will appear here"
            )
        }
    }
}

// MARK: - Grant Row

enum AccessGrantRowVariant: Sendable {
    case given
    case received
}

struct AccessGrantRow: View {
    let grant: AccessGrant
    var variant: AccessGrantRowVariant = .given
    let revokeAction: (() -> Void)?

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(displayName)
                    .font(Typography.headline)
                Spacer()
                StatusBadge(accessGrantStatus: grant.status)
            }

            if let reason = grant.grantReason {
                Text(reason)
                    .font(Typography.caption)
                    .foregroundStyle(.secondary)
            }

            HStack {
                Text(scopeDescription)
                    .font(Typography.caption)
                    .foregroundStyle(.secondary)

                Spacer()

                if let expires = grant.expiresAt {
                    Text("Expires \(expires.formatted(date: .abbreviated, time: .omitted))")
                        .font(Typography.caption)
                        .foregroundStyle(.tertiary)
                }
            }

            if let revokeAction, grant.status == .active {
                Button("Revoke Access", role: .destructive, action: revokeAction)
                    .font(Typography.caption)
            }
        }
    }

    private var displayName: String {
        switch variant {
        case .given:
            grant.grantedToUserName ?? "Unknown User"
        case .received:
            grant.grantedByUserName ?? "Unknown Patient"
        }
    }

    private var scopeDescription: String {
        grant.scope.allReports ? "All Reports" : "\(grant.scope.reportIds.count) reports"
    }
}
