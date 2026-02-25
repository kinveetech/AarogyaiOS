import SwiftUI

struct RejectedRegistrationView: View {
    let reason: String?
    let onSignOut: () -> Void

    var body: some View {
        VStack(spacing: 24) {
            Spacer()

            Image(systemName: "exclamationmark.triangle.fill")
                .font(.system(size: 64))
                .foregroundStyle(Color.Fallback.statusCritical)

            Text("Registration Not Approved")
                .font(Typography.title)
                .multilineTextAlignment(.center)

            if let reason, !reason.isEmpty {
                VStack(spacing: 8) {
                    Text("Reason")
                        .font(Typography.subheadline)
                        .foregroundStyle(.secondary)
                    Text(reason)
                        .font(Typography.body)
                        .multilineTextAlignment(.center)
                }
                .padding(16)
                .background(Color.Fallback.bgSecondary, in: RoundedRectangle(cornerRadius: 12))
            }

            Text("If you believe this is an error, please contact our support team.")
                .font(Typography.callout)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)

            Spacer()

            VStack(spacing: 12) {
                PrimaryButton("Contact Support", icon: "envelope") {
                    // Open email or support URL
                }

                Button("Sign Out", action: onSignOut)
                    .font(Typography.subheadline)
                    .foregroundStyle(.secondary)
            }
        }
        .padding(32)
        .sereneBloomBackground()
    }
}
