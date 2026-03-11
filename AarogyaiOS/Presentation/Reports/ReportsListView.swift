import SwiftUI

struct ReportsListView: View {
    @State var viewModel: ReportsListViewModel
    @State private var showUpload = false

    var body: some View {
        ZStack(alignment: .bottomTrailing) {
            reportsList

            GlassFAB(icon: "plus") {
                showUpload = true
            }
            .accessibilityIdentifier(AccessibilityID.Reports.fab)
            .padding(24)
        }
        .navigationTitle("Reports")
        .searchable(text: $viewModel.searchQuery, prompt: "Search reports")
        .onSubmit(of: .search) { viewModel.search() }
        .refreshable { await viewModel.refresh() }
        .task { await viewModel.loadReports() }
        .onAppear { Task { await viewModel.refreshIfNeeded() } }
        .sheet(isPresented: $showUpload) {
            Text("Upload Report") // Placeholder for ReportUploadView
        }
    }

    private var reportsList: some View {
        Group {
            if viewModel.isLoading && viewModel.reports.isEmpty {
                LoadingView("Loading reports...")
            } else if viewModel.reports.isEmpty {
                EmptyStateView(
                    icon: "doc.text",
                    title: "No reports yet",
                    subtitle: "Upload your first medical report to get started",
                    actionTitle: "Upload Report"
                ) {
                    showUpload = true
                }
            } else {
                ScrollView {
                    LazyVStack(spacing: 0) {
                        GlassFilterBar(
                            items: ReportType.allCases,
                            selection: $viewModel.selectedFilter
                        ) { type in
                            type.rawValue.replacingOccurrences(of: "_", with: " ").capitalized
                        }
                        .padding(.vertical, 8)
                        .onChange(of: viewModel.selectedFilter) {
                            viewModel.applyFilter(viewModel.selectedFilter)
                        }

                        LazyVStack(spacing: 12) {
                            ForEach(viewModel.reports) { report in
                                NavigationLink(value: Route.reportDetail(id: report.id)) {
                                    ReportCard(report: report)
                                }
                                .buttonStyle(.plain)
                            }

                            if viewModel.hasMorePages {
                                ProgressView()
                                    .padding()
                                    .task { await viewModel.loadMore() }
                            }
                        }
                        .padding(.horizontal, 16)
                    }
                }
            }
        }
    }
}
