import SwiftUI

struct PendingApprovalView: View {
    let checkStatusUseCase: CheckRegistrationStatusUseCase
    let onStatusChange: (RegistrationStatus) -> Void
    let onSignOut: () -> Void

    @State private var isChecking = false

    var body: some View {
        VStack(spacing: 24) {
            Spacer()

            Image(systemName: "hourglass")
                .font(.system(size: 64))
                .foregroundStyle(Color.Fallback.brandAccent)

            Text("Registration Under Review")
                .font(Typography.title)
                .multilineTextAlignment(.center)

            Text("Your registration is being reviewed by our team. This typically takes 1-2 business days.")
                .font(Typography.callout)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)

            Text("You'll be notified when your account is approved.")
                .font(Typography.subheadline)
                .foregroundStyle(.tertiary)
                .multilineTextAlignment(.center)

            Spacer()

            VStack(spacing: 12) {
                PrimaryButton(
                    "Check Status",
                    icon: "arrow.clockwise",
                    isLoading: isChecking
                ) {
                    Task { await checkStatus() }
                }

                Button("Sign Out", action: onSignOut)
                    .font(Typography.subheadline)
                    .foregroundStyle(.secondary)
            }
        }
        .padding(32)
        .sereneBloomBackground()
    }

    private func checkStatus() async {
        isChecking = true
        defer { isChecking = false }

        do {
            let status = try await checkStatusUseCase.execute()
            onStatusChange(status)
        } catch {
            // Stay on current screen if check fails
        }
    }
}
