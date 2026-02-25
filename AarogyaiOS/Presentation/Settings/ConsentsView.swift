import SwiftUI

struct ConsentsView: View {
    @State var viewModel: ConsentsViewModel

    var body: some View {
        Group {
            if viewModel.isLoading {
                LoadingView("Loading consents...")
            } else {
                consentsList
            }
        }
        .navigationTitle("Privacy & Consents")
        .task { await viewModel.loadConsents() }
        .alert("Error", isPresented: .constant(viewModel.error != nil)) {
            Button("OK") { viewModel.error = nil }
        } message: {
            if let error = viewModel.error {
                Text(error)
            }
        }
    }

    private var consentsList: some View {
        List {
            Section {
                Text("Manage your data processing consents as per DPDPA regulations.")
                    .font(Typography.callout)
                    .foregroundStyle(.secondary)
            }

            ForEach(ConsentPurpose.allCases, id: \.self) { purpose in
                Section {
                    Toggle(isOn: Binding(
                        get: { viewModel.isGranted(purpose) },
                        set: { newValue in
                            Task { await viewModel.toggleConsent(purpose: purpose, isGranted: newValue) }
                        }
                    )) {
                        VStack(alignment: .leading, spacing: 4) {
                            Text(purpose.displayName)
                                .font(Typography.headline)
                            Text(purpose.description)
                                .font(Typography.caption)
                                .foregroundStyle(.secondary)
                        }
                    }
                    .disabled(purpose.isRequired)

                    if purpose.isRequired {
                        Text("Required for core functionality")
                            .font(Typography.caption)
                            .foregroundStyle(.tertiary)
                    }
                }
            }
        }
    }
}
