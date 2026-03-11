import SwiftUI

struct ProfileEditView: View {
    @State var viewModel: ProfileEditViewModel

    var body: some View {
        Group {
            if viewModel.isLoading {
                LoadingView("Loading profile...")
            } else {
                profileForm
            }
        }
        .navigationTitle("Profile")
        .task { await viewModel.loadProfile() }
        .alert("Error", isPresented: .constant(viewModel.error != nil)) {
            Button("OK") { viewModel.error = nil }
        } message: {
            if let error = viewModel.error {
                Text(error)
            }
        }
    }

    private var profileForm: some View {
        Form {
            if viewModel.saveSuccess {
                Section {
                    Label("Profile updated successfully", systemImage: "checkmark.circle.fill")
                        .foregroundStyle(.green)
                        .accessibilityIdentifier(AccessibilityID.Profile.successBanner)
                }
            }

            Section("Personal Information") {
                VStack(alignment: .leading, spacing: 4) {
                    TextField("First Name", text: $viewModel.firstName)
                        .textContentType(.givenName)
                        .accessibilityIdentifier(AccessibilityID.Profile.firstNameField)
                        .onChange(of: viewModel.firstName) {
                            viewModel.clearValidationError(for: "firstName")
                        }
                    validationMessage(for: "firstName")
                }

                VStack(alignment: .leading, spacing: 4) {
                    TextField("Last Name", text: $viewModel.lastName)
                        .textContentType(.familyName)
                        .accessibilityIdentifier(AccessibilityID.Profile.lastNameField)
                        .onChange(of: viewModel.lastName) {
                            viewModel.clearValidationError(for: "lastName")
                        }
                    validationMessage(for: "lastName")
                }

                TextField("Email", text: $viewModel.email)
                    .textContentType(.emailAddress)
                    .keyboardType(.emailAddress)
                    .disabled(true)
                    .accessibilityIdentifier(AccessibilityID.Profile.emailField)

                TextField("Phone", text: $viewModel.phone)
                    .textContentType(.telephoneNumber)
                    .keyboardType(.phonePad)
                    .disabled(true)
                    .accessibilityIdentifier(AccessibilityID.Profile.phoneField)
            }

            Section("Health Information") {
                Picker("Blood Group", selection: $viewModel.bloodGroup) {
                    Text("Not Set").tag(BloodGroup?.none)
                    ForEach(BloodGroup.allCases, id: \.self) { group in
                        Text(group.rawValue).tag(BloodGroup?.some(group))
                    }
                }
                .accessibilityIdentifier(AccessibilityID.Profile.bloodGroupPicker)

                VStack(alignment: .leading, spacing: 4) {
                    DatePicker(
                        "Date of Birth",
                        selection: Binding(
                            get: { viewModel.dateOfBirth ?? .now },
                            set: {
                                viewModel.dateOfBirth = $0
                                viewModel.clearValidationError(for: "dateOfBirth")
                            }
                        ),
                        displayedComponents: .date
                    )
                    .accessibilityIdentifier(AccessibilityID.Profile.dateOfBirthPicker)
                    validationMessage(for: "dateOfBirth")
                }

                Picker("Gender", selection: $viewModel.gender) {
                    Text("Not Set").tag(Gender?.none)
                    ForEach(Gender.allCases, id: \.self) { gender in
                        Text(gender.rawValue.capitalized).tag(Gender?.some(gender))
                    }
                }
                .accessibilityIdentifier(AccessibilityID.Profile.genderPicker)
            }

            Section("Address") {
                TextField("Address", text: Binding(
                    get: { viewModel.address ?? "" },
                    set: { viewModel.address = $0.isEmpty ? nil : $0 }
                ), axis: .vertical)
                    .lineLimit(2...4)
                    .accessibilityIdentifier(AccessibilityID.Profile.addressField)
            }

            Section {
                Button {
                    Task { await viewModel.saveProfile() }
                } label: {
                    if viewModel.isSaving {
                        ProgressView()
                            .frame(maxWidth: .infinity, alignment: .center)
                    } else {
                        Text("Save Changes")
                            .frame(maxWidth: .infinity, alignment: .center)
                    }
                }
                .accessibilityIdentifier(AccessibilityID.Profile.saveButton)
                .disabled(!viewModel.canSave)
            }
        }
    }

    @ViewBuilder
    private func validationMessage(for field: String) -> some View {
        if let message = viewModel.validationErrors[field] {
            Text(message)
                .font(.caption)
                .foregroundStyle(.red)
                .accessibilityIdentifier(AccessibilityID.Profile.validationError(field))
        }
    }
}
