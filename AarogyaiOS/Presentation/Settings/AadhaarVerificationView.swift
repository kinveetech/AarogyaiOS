import SwiftUI

struct AadhaarVerificationView: View {
    @State var viewModel: AadhaarVerificationViewModel

    var body: some View {
        Group {
            if case .loading = viewModel.state, viewModel.user == nil {
                LoadingView("Loading verification status...")
            } else {
                content
            }
        }
        .navigationTitle("Aadhaar Verification")
        .task { await viewModel.loadCurrentUser() }
        .alert("Error", isPresented: .constant(viewModel.errorMessage != nil)) {
            Button("OK") { viewModel.dismissError() }
        } message: {
            if let error = viewModel.errorMessage {
                Text(error)
            }
        }
    }

    @ViewBuilder
    private var content: some View {
        List {
            if viewModel.isAlreadyVerified {
                verifiedSection
            } else {
                unverifiedSection
                inputSection
            }
        }
    }

    // MARK: - Verified State

    private var verifiedSection: some View {
        Section {
            VStack(alignment: .center, spacing: 16) {
                Image(systemName: "checkmark.seal.fill")
                    .font(.system(size: 56))
                    .foregroundStyle(Color.Fallback.statusNormal)
                    .accessibilityIdentifier(AccessibilityID.AadhaarVerification.verifiedIcon)

                Text("Aadhaar Verified")
                    .font(Typography.title2)
                    .accessibilityIdentifier(AccessibilityID.AadhaarVerification.verifiedTitle)

                if !viewModel.maskedAadhaarRef.isEmpty {
                    Text(viewModel.maskedAadhaarRef)
                        .font(Typography.data)
                        .foregroundStyle(.secondary)
                        .accessibilityIdentifier(
                            AccessibilityID.AadhaarVerification.maskedToken
                        )
                }

                if let user = viewModel.user {
                    verifiedUserDetails(user)
                }
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
        }
    }

    private func verifiedUserDetails(_ user: User) -> some View {
        VStack(spacing: 8) {
            HStack {
                Text("Name")
                    .font(Typography.subheadline)
                    .foregroundStyle(.secondary)
                Spacer()
                Text("\(user.firstName) \(user.lastName)")
                    .font(Typography.body)
            }

            if let gender = user.gender {
                HStack {
                    Text("Gender")
                        .font(Typography.subheadline)
                        .foregroundStyle(.secondary)
                    Spacer()
                    Text(gender.rawValue.capitalized)
                        .font(Typography.body)
                }
            }

            if let dob = user.dateOfBirth {
                HStack {
                    Text("Date of Birth")
                        .font(Typography.subheadline)
                        .foregroundStyle(.secondary)
                    Spacer()
                    Text(dob.formatted(date: .abbreviated, time: .omitted))
                        .font(Typography.body)
                }
            }
        }
        .padding(.top, 8)
        .accessibilityIdentifier(AccessibilityID.AadhaarVerification.userDetails)
    }

    // MARK: - Unverified State

    private var unverifiedSection: some View {
        Section {
            VStack(alignment: .center, spacing: 12) {
                Image(systemName: "person.badge.shield.checkmark")
                    .font(.system(size: 48))
                    .foregroundStyle(Color.Fallback.brandPrimary)
                    .accessibilityIdentifier(
                        AccessibilityID.AadhaarVerification.unverifiedIcon
                    )

                Text("Verify Your Aadhaar")
                    .font(Typography.title2)
                    .accessibilityIdentifier(
                        AccessibilityID.AadhaarVerification.unverifiedTitle
                    )

                Text(
                    "Enter your Aadhaar reference token to verify your identity. "
                    + "Your full Aadhaar number is never stored or displayed."
                )
                    .font(Typography.callout)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 12)
        }
    }

    private var inputSection: some View {
        Section("Verification") {
            VStack(alignment: .leading, spacing: 8) {
                Text("Aadhaar Reference Token")
                    .font(Typography.subheadline)
                    .foregroundStyle(.secondary)

                SecureField("Enter reference token", text: $viewModel.aadhaarRefToken)
                    .textContentType(.oneTimeCode)
                    .autocorrectionDisabled()
                    .textInputAutocapitalization(.never)
                    .accessibilityIdentifier(
                        AccessibilityID.AadhaarVerification.tokenField
                    )
            }

            Button {
                Task { await viewModel.verifyAadhaar() }
            } label: {
                if viewModel.isVerifying {
                    ProgressView()
                        .frame(maxWidth: .infinity, alignment: .center)
                } else {
                    Text("Verify Aadhaar")
                        .frame(maxWidth: .infinity, alignment: .center)
                }
            }
            .disabled(!viewModel.canSubmit)
            .accessibilityIdentifier(AccessibilityID.AadhaarVerification.verifyButton)
        }
    }
}

#if DEBUG
#Preview("Unverified") {
    NavigationStack {
        AadhaarVerificationView(
            viewModel: AadhaarVerificationViewModel(
                verifyAadhaarUseCase: VerifyAadhaarUseCase(
                    userRepository: PreviewUserRepository()
                ),
                getCurrentUserUseCase: GetCurrentUserUseCase(
                    userRepository: PreviewUserRepository()
                )
            )
        )
    }
}

private struct PreviewUserRepository: UserRepository {
    private static var previewUser: User {
        User(
            id: "preview-1", firstName: "Priya", lastName: "Sharma",
            email: "priya@example.com", phone: "+919876543210",
            address: nil, bloodGroup: .oPositive,
            dateOfBirth: Date(timeIntervalSince1970: 946_684_800),
            gender: .female, role: .patient, registrationStatus: .approved,
            isAadhaarVerified: false, aadhaarRefToken: nil,
            doctorProfile: nil, labTechProfile: nil,
            createdAt: .now, updatedAt: .now
        )
    }

    func getProfile() async throws -> User { Self.previewUser }
    func updateProfile(_ user: User) async throws -> User { user }
    func register(request: RegistrationRequest) async throws -> User { Self.previewUser }
    func getRegistrationStatus() async throws -> RegistrationStatus { .approved }
    func verifyAadhaar(token: String) async throws -> User {
        var user = Self.previewUser
        user.isAadhaarVerified = true
        user.aadhaarRefToken = "ABCD1234EFGH"
        return user
    }
    func exportData() async throws {}
    func requestDeletion() async throws {}
}
#endif
