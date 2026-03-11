import SwiftUI

struct EmergencyAccessRequestFormView: View {
    @Bindable var viewModel: EmergencyContactsViewModel
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            Form {
                if let contact = viewModel.accessRequestContact {
                    contactSection(contact)
                }
                requestDetailsSection
                durationSection
            }
            .navigationTitle("Emergency Access")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Request") {
                        Task { await viewModel.submitAccessRequest() }
                    }
                    .disabled(!isFormValid || viewModel.isRequestingAccess)
                }
            }
            .overlay {
                if viewModel.isRequestingAccess {
                    LoadingView("Requesting access...")
                }
            }
            .disabled(viewModel.isRequestingAccess)
        }
    }

    private func contactSection(_ contact: EmergencyContact) -> some View {
        Section("Emergency Contact") {
            LabeledContent("Name", value: contact.name)
            LabeledContent("Relationship", value: contact.relationship.rawValue.capitalized)
        }
    }

    private var requestDetailsSection: some View {
        Section("Request Details") {
            TextField("Patient Identifier", text: $viewModel.accessRequestPatientSub)
                .textContentType(.username)
                .autocorrectionDisabled()
                .textInputAutocapitalization(.never)
            TextField("Doctor Identifier", text: $viewModel.accessRequestDoctorSub)
                .textContentType(.username)
                .autocorrectionDisabled()
                .textInputAutocapitalization(.never)
            TextField("Reason for Emergency Access", text: $viewModel.accessRequestReason, axis: .vertical)
                .lineLimit(3...6)
        }
    }

    private var durationSection: some View {
        Section {
            Picker("Duration", selection: durationBinding) {
                Text("Default (24 hours)").tag(0)
                Text("12 hours").tag(12)
                Text("24 hours").tag(24)
                Text("48 hours").tag(48)
                Text("72 hours").tag(72)
            }
        } header: {
            Text("Access Duration")
        } footer: {
            Text("Emergency access is time-bound and fully audited.")
                .font(Typography.caption)
        }
    }

    private var durationBinding: Binding<Int> {
        Binding(
            get: { viewModel.accessRequestDurationHours ?? 0 },
            set: { viewModel.accessRequestDurationHours = $0 == 0 ? nil : $0 }
        )
    }

    private var isFormValid: Bool {
        !viewModel.accessRequestPatientSub.isEmpty
            && !viewModel.accessRequestDoctorSub.isEmpty
            && !viewModel.accessRequestReason.isEmpty
    }
}
