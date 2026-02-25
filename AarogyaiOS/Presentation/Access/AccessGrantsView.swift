import SwiftUI

struct AccessGrantsView: View {
    @State var viewModel: AccessGrantsViewModel

    var body: some View {
        Group {
            if viewModel.isLoading && viewModel.grantedGrants.isEmpty {
                LoadingView("Loading access grants...")
            } else if viewModel.grantedGrants.isEmpty && viewModel.receivedGrants.isEmpty {
                EmptyStateView(
                    icon: "person.2",
                    title: "No access grants",
                    subtitle: "Grant doctors access to your medical reports",
                    actionTitle: "Grant Access"
                ) {
                    viewModel.showCreateGrant = true
                }
            } else {
                grantsList
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

    private var grantsList: some View {
        List {
            if !viewModel.grantedGrants.isEmpty {
                Section("Granted by You") {
                    ForEach(viewModel.grantedGrants) { grant in
                        AccessGrantRow(grant: grant) {
                            Task { await viewModel.revokeGrant(grant) }
                        }
                    }
                }
            }

            if !viewModel.receivedGrants.isEmpty {
                Section("Granted to You") {
                    ForEach(viewModel.receivedGrants) { grant in
                        AccessGrantRow(grant: grant, revokeAction: nil)
                    }
                }
            }
        }
    }
}

struct AccessGrantRow: View {
    let grant: AccessGrant
    let revokeAction: (() -> Void)?

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(grant.grantedToUserName ?? "Unknown User")
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
                Text(grant.scope.allReports ? "All Reports" : "\(grant.scope.reportIds.count) reports")
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
}
