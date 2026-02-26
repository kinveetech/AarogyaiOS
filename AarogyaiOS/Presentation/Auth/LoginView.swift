import SwiftUI

struct LoginView: View {
    @State var viewModel: LoginViewModel
    @State private var showBranding = false
    @State private var showSocialButtons = false
    @State private var showDivider = false
    @State private var showPhoneSection = false
    @State private var showFooter = false

    var body: some View {
        VStack(spacing: 32) {
            Spacer()

            branding
                .opacity(showBranding ? 1 : 0)
                .scaleEffect(showBranding ? 1 : 0.8)

            socialLoginButtons
                .opacity(showSocialButtons ? 1 : 0)
                .offset(y: showSocialButtons ? 0 : 24)

            divider
                .opacity(showDivider ? 1 : 0)

            phoneLoginSection
                .opacity(showPhoneSection ? 1 : 0)
                .offset(y: showPhoneSection ? 0 : 20)

            Spacer()

            termsFooter
                .opacity(showFooter ? 1 : 0)
        }
        .padding(24)
        .sereneBloomBackground()
        .task {
            withAnimation(.spring(response: 0.7, dampingFraction: 0.8)) {
                showBranding = true
            }
            try? await Task.sleep(for: .milliseconds(200))
            withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                showSocialButtons = true
            }
            try? await Task.sleep(for: .milliseconds(150))
            withAnimation(.easeOut(duration: 0.4)) {
                showDivider = true
            }
            try? await Task.sleep(for: .milliseconds(150))
            withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                showPhoneSection = true
            }
            try? await Task.sleep(for: .milliseconds(200))
            withAnimation(.easeOut(duration: 0.5)) {
                showFooter = true
            }
        }
    }

    // MARK: - Branding

    private var branding: some View {
        ShieldTreeLogo(size: 80, showWordmark: true)
            .accessibilityIdentifier(AccessibilityID.Login.title)
    }

    // MARK: - Social Login

    private var socialLoginButtons: some View {
        VStack(spacing: 12) {
            SocialLoginButton(provider: .apple) {
                Task { await viewModel.loginWithSocial(provider: .apple) }
            }
            .disabled(viewModel.isLoading)
            SocialLoginButton(provider: .google) {
                Task { await viewModel.loginWithSocial(provider: .google) }
            }
            .disabled(viewModel.isLoading)
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
                    .transition(.asymmetric(
                        insertion: .move(edge: .trailing).combined(with: .opacity),
                        removal: .move(edge: .leading).combined(with: .opacity)
                    ))
            } else {
                phoneInput
                    .transition(.asymmetric(
                        insertion: .move(edge: .leading).combined(with: .opacity),
                        removal: .move(edge: .leading).combined(with: .opacity)
                    ))
            }

            if let error = viewModel.error {
                Text(error)
                    .font(Typography.caption)
                    .foregroundStyle(Color.Fallback.statusCritical)
                    .multilineTextAlignment(.center)
                    .transition(.opacity.combined(with: .scale(scale: 0.95)))
            }
        }
        .animation(.spring(response: 0.5, dampingFraction: 0.85), value: viewModel.otpSent)
        .animation(.easeOut(duration: 0.3), value: viewModel.error)
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
