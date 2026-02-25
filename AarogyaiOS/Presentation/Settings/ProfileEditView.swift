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
            Section("Personal Information") {
                TextField("First Name", text: $viewModel.firstName)
                    .textContentType(.givenName)
                TextField("Last Name", text: $viewModel.lastName)
                    .textContentType(.familyName)
                TextField("Email", text: $viewModel.email)
                    .textContentType(.emailAddress)
                    .keyboardType(.emailAddress)
                    .disabled(true)
                TextField("Phone", text: $viewModel.phone)
                    .textContentType(.telephoneNumber)
                    .keyboardType(.phonePad)
                    .disabled(true)
            }

            Section("Health Information") {
                Picker("Blood Group", selection: $viewModel.bloodGroup) {
                    Text("Not Set").tag(BloodGroup?.none)
                    ForEach(BloodGroup.allCases, id: \.self) { group in
                        Text(group.rawValue).tag(BloodGroup?.some(group))
                    }
                }

                DatePicker(
                    "Date of Birth",
                    selection: Binding(
                        get: { viewModel.dateOfBirth ?? .now },
                        set: { viewModel.dateOfBirth = $0 }
                    ),
                    displayedComponents: .date
                )

                Picker("Gender", selection: $viewModel.gender) {
                    Text("Not Set").tag(Gender?.none)
                    ForEach(Gender.allCases, id: \.self) { gender in
                        Text(gender.rawValue.capitalized).tag(Gender?.some(gender))
                    }
                }
            }

            Section("Address") {
                TextField("Address", text: Binding(
                    get: { viewModel.address ?? "" },
                    set: { viewModel.address = $0.isEmpty ? nil : $0 }
                ), axis: .vertical)
                    .lineLimit(2...4)
            }

            Section {
                Button("Save Changes") {
                    Task { await viewModel.saveProfile() }
                }
                .disabled(!viewModel.hasChanges || viewModel.isSaving)
                .frame(maxWidth: .infinity, alignment: .center)
            }
        }
    }
}
