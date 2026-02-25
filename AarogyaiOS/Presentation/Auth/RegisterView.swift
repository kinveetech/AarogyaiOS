import SwiftUI

struct RegisterView: View {
    @State var viewModel: RegisterViewModel

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                stepIndicator

                ScrollView {
                    VStack(spacing: 24) {
                        switch viewModel.currentStep {
                        case .roleSelection:
                            roleSelectionStep
                        case .profileInfo:
                            profileInfoStep
                        case .consents:
                            consentsStep
                        }

                        if let error = viewModel.error {
                            Text(error)
                                .font(Typography.caption)
                                .foregroundStyle(Color.Fallback.statusCritical)
                                .multilineTextAlignment(.center)
                        }
                    }
                    .padding(24)
                }

                navigationButtons
            }
            .sereneBloomBackground()
            .navigationTitle("Create Account")
            .navigationBarTitleDisplayMode(.inline)
        }
    }

    // MARK: - Step Indicator

    private var stepIndicator: some View {
        HStack(spacing: 8) {
            ForEach(RegisterViewModel.Step.allCases, id: \.rawValue) { step in
                Capsule()
                    .fill(step.rawValue <= viewModel.currentStep.rawValue
                          ? Color.Fallback.brandPrimary
                          : Color.Fallback.borderDefault)
                    .frame(height: 4)
            }
        }
        .padding(.horizontal, 24)
        .padding(.vertical, 8)
    }

    // MARK: - Step 1: Role Selection

    private var roleSelectionStep: some View {
        VStack(spacing: 16) {
            Text("Choose your role")
                .font(Typography.title)

            ForEach([UserRole.patient, .doctor, .labTechnician], id: \.self) { role in
                RoleSelectionCard(
                    role: role,
                    isSelected: viewModel.selectedRole == role
                ) {
                    withAnimation(.smooth) {
                        viewModel.selectedRole = role
                    }
                }
            }
        }
    }

    // MARK: - Step 2: Profile Form

    private var profileInfoStep: some View {
        VStack(spacing: 16) {
            Text("Your information")
                .font(Typography.title)

            FormField("First Name", text: $viewModel.firstName, icon: "person")
            FormField("Last Name", text: $viewModel.lastName, icon: "person")
            FormField("Email", text: $viewModel.email, icon: "envelope", keyboardType: .emailAddress)
            FormField("Phone", text: $viewModel.phone, icon: "phone", keyboardType: .phonePad)

            DatePicker("Date of Birth", selection: Binding(
                get: { viewModel.dateOfBirth ?? Date() },
                set: { viewModel.dateOfBirth = $0 }
            ), displayedComponents: .date)
            .font(Typography.body)

            if viewModel.selectedRole == .doctor {
                doctorFields
            } else if viewModel.selectedRole == .labTechnician {
                labTechFields
            }
        }
    }

    private var doctorFields: some View {
        Group {
            Divider()
            Text("Doctor Details")
                .font(Typography.headline)
                .frame(maxWidth: .infinity, alignment: .leading)

            FormField("Medical License Number", text: $viewModel.medicalLicense, icon: "doc.text")
            FormField("Specialization", text: $viewModel.specialization, icon: "stethoscope")
            FormField("Clinic Name", text: $viewModel.clinicName, icon: "building.2")
            FormField("Clinic Address", text: $viewModel.clinicAddress, icon: "mappin")
        }
    }

    private var labTechFields: some View {
        Group {
            Divider()
            Text("Lab Details")
                .font(Typography.headline)
                .frame(maxWidth: .infinity, alignment: .leading)

            FormField("Lab Name", text: $viewModel.labName, icon: "building.2")
            FormField("Lab License Number", text: $viewModel.labLicense, icon: "doc.text")
            FormField("NABL Accreditation ID", text: $viewModel.nablAccreditation, icon: "checkmark.seal")
        }
    }

    // MARK: - Step 3: Consents

    private var consentsStep: some View {
        VStack(spacing: 16) {
            Text("Consent & Privacy")
                .font(Typography.title)

            Text("We need your consent to process your data under DPDPA regulations.")
                .font(Typography.callout)
                .foregroundStyle(.secondary)

            ForEach(ConsentPurpose.allCases, id: \.self) { purpose in
                ConsentToggleRow(
                    purpose: purpose,
                    isGranted: Binding(
                        get: { viewModel.consentStates[purpose] ?? false },
                        set: { viewModel.consentStates[purpose] = $0 }
                    )
                )
            }
        }
    }

    // MARK: - Navigation Buttons

    private var navigationButtons: some View {
        HStack(spacing: 12) {
            if viewModel.currentStep != .roleSelection {
                SecondaryButton("Back", icon: "chevron.left") {
                    viewModel.previousStep()
                }
            }

            switch viewModel.currentStep {
            case .roleSelection:
                PrimaryButton("Continue", icon: "chevron.right") {
                    viewModel.nextStep()
                }
                .disabled(!viewModel.canProceedFromStep1)
            case .profileInfo:
                PrimaryButton("Continue", icon: "chevron.right") {
                    viewModel.nextStep()
                }
                .disabled(!viewModel.canProceedFromStep2)
            case .consents:
                PrimaryButton("Register", icon: "checkmark", isLoading: viewModel.isLoading) {
                    Task { await viewModel.submit() }
                }
                .disabled(!viewModel.canSubmit)
            }
        }
        .padding(24)
    }
}

// MARK: - Supporting Components

private struct FormField: View {
    let placeholder: String
    @Binding var text: String
    let icon: String
    var keyboardType: UIKeyboardType = .default

    init(
        _ placeholder: String,
        text: Binding<String>,
        icon: String,
        keyboardType: UIKeyboardType = .default
    ) {
        self.placeholder = placeholder
        self._text = text
        self.icon = icon
        self.keyboardType = keyboardType
    }

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .foregroundStyle(.secondary)
                .frame(width: 20)

            TextField(placeholder, text: $text)
                .font(Typography.body)
                .keyboardType(keyboardType)
        }
        .padding(12)
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 12))
    }
}

struct RoleSelectionCard: View {
    let role: UserRole
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 16) {
                Image(systemName: roleIcon)
                    .font(.title2)
                    .foregroundStyle(isSelected ? Color.Fallback.brandPrimary : .secondary)
                    .frame(width: 44, height: 44)
                    .background(
                        (isSelected ? Color.Fallback.brandPrimaryLight : Color.Fallback.borderDefault)
                            .opacity(0.2),
                        in: Circle()
                    )

                VStack(alignment: .leading, spacing: 4) {
                    Text(role.rawValue.capitalized)
                        .font(Typography.headline)
                    Text(roleDescription)
                        .font(Typography.caption)
                        .foregroundStyle(.secondary)
                }

                Spacer()

                if isSelected {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundStyle(Color.Fallback.brandPrimary)
                }
            }
            .padding(16)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color.Fallback.bgSecondary)
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .strokeBorder(
                                isSelected ? Color.Fallback.brandPrimary : .clear,
                                lineWidth: 2
                            )
                    )
            )
        }
        .buttonStyle(.plain)
    }

    private var roleIcon: String {
        switch role {
        case .patient: "person.fill"
        case .doctor: "stethoscope"
        case .labTechnician: "flask.fill"
        case .admin: "shield.fill"
        }
    }

    private var roleDescription: String {
        switch role {
        case .patient: "Manage your medical records"
        case .doctor: "Access patient records with consent"
        case .labTechnician: "Upload and manage lab reports"
        case .admin: "Platform administration"
        }
    }
}

struct ConsentToggleRow: View {
    let purpose: ConsentPurpose
    @Binding var isGranted: Bool

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            VStack(alignment: .leading, spacing: 4) {
                HStack(spacing: 4) {
                    Text(purpose.displayName)
                        .font(Typography.headline)
                    if purpose.isRequired {
                        Text("Required")
                            .font(Typography.caption)
                            .foregroundStyle(Color.Fallback.statusCritical)
                    }
                }
                Text(purpose.description)
                    .font(Typography.caption)
                    .foregroundStyle(.secondary)
            }

            Spacer()

            Toggle("", isOn: $isGranted)
                .labelsHidden()
                .disabled(purpose.isRequired)
        }
        .padding(12)
        .background(Color.Fallback.bgSecondary, in: RoundedRectangle(cornerRadius: 12))
    }
}
