import SwiftUI

struct LoginView: View {
    @State var viewModel: LoginViewModel

    var body: some View {
        VStack(spacing: 32) {
            Spacer()

            branding

            socialLoginButtons

            divider

            phoneLoginSection

            Spacer()

            termsFooter
        }
        .padding(24)
        .sereneBloomBackground()
    }

    // MARK: - Branding

    private var branding: some View {
        VStack(spacing: 8) {
            Image(systemName: "heart.text.clipboard")
                .font(.system(size: 56))
                .foregroundStyle(Color.Fallback.brandPrimary)

            Text("Aarogya")
                .font(Typography.largeTitle)
                .accessibilityIdentifier(AccessibilityID.Login.title)

            Text("Your health records, secured")
                .font(Typography.callout)
                .foregroundStyle(.secondary)
        }
    }

    // MARK: - Social Login

    private var socialLoginButtons: some View {
        VStack(spacing: 12) {
            SocialLoginButton(provider: .apple) {
                // Social login handled in future iteration
            }
            SocialLoginButton(provider: .google) {
                // Social login handled in future iteration
            }
        }
    }

    // MARK: - Divider

    private var divider: some View {
        HStack {
            Rectangle().frame(height: 1).foregroundStyle(.tertiary)
            Text("or")
                .font(Typography.caption)
                .foregroundStyle(.secondary)
            Rectangle().frame(height: 1).foregroundStyle(.tertiary)
        }
    }

    // MARK: - Phone Login

    private var phoneLoginSection: some View {
        VStack(spacing: 16) {
            if viewModel.otpSent {
                otpInput
            } else {
                phoneInput
            }

            if let error = viewModel.error {
                Text(error)
                    .font(Typography.caption)
                    .foregroundStyle(Color.Fallback.statusCritical)
                    .multilineTextAlignment(.center)
            }
        }
    }

    private var phoneInput: some View {
        VStack(spacing: 12) {
            HStack(spacing: 8) {
                Text("+91")
                    .font(Typography.body)
                    .foregroundStyle(.secondary)
                    .padding(.leading, 12)

                TextField("Phone number", text: $viewModel.phone)
                    .font(Typography.body)
                    .keyboardType(.phonePad)
                    .textContentType(.telephoneNumber)
                    .accessibilityIdentifier(AccessibilityID.Login.phoneField)
            }
            .padding(12)
            .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 12))

            PrimaryButton("Send OTP", icon: "arrow.right", isLoading: viewModel.isLoading) {
                Task { await viewModel.requestOTP() }
            }
            .accessibilityIdentifier(AccessibilityID.Login.sendOTPButton)
        }
    }

    private var otpInput: some View {
        VStack(spacing: 12) {
            Text("Enter the 6-digit code sent to +91\(viewModel.phone)")
                .font(Typography.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)

            TextField("000000", text: $viewModel.otp)
                .font(Typography.data)
                .keyboardType(.numberPad)
                .textContentType(.oneTimeCode)
                .multilineTextAlignment(.center)
                .padding(12)
                .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 12))
                .accessibilityIdentifier(AccessibilityID.Login.otpField)

            PrimaryButton("Verify", icon: "checkmark", isLoading: viewModel.isLoading) {
                Task { await viewModel.verifyOTP() }
            }
            .accessibilityIdentifier(AccessibilityID.Login.verifyButton)

            Button("Change number") {
                viewModel.resetOTP()
            }
            .font(Typography.subheadline)
            .foregroundStyle(Color.Fallback.brandPrimary)
        }
    }

    // MARK: - Footer

    private var termsFooter: some View {
        Text("By signing in, you agree to our Terms of Service and Privacy Policy")
            .font(Typography.caption)
            .foregroundStyle(.tertiary)
            .multilineTextAlignment(.center)
    }
}
