import SwiftUI

struct ErrorBannerView: View {
    let message: String
    let retryAction: (() -> Void)?
    let dismissAction: () -> Void

    init(
        message: String,
        retryAction: (() -> Void)? = nil,
        dismissAction: @escaping () -> Void
    ) {
        self.message = message
        self.retryAction = retryAction
        self.dismissAction = dismissAction
    }

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: "exclamationmark.triangle.fill")
                .foregroundStyle(Color.Fallback.statusCritical)

            Text(message)
                .font(Typography.subheadline)
                .lineLimit(2)

            Spacer()

            if let retryAction {
                Button("Retry", action: retryAction)
                    .font(Typography.subheadline.weight(.semibold))
            }

            Button(action: dismissAction) {
                Image(systemName: "xmark")
                    .font(.caption)
            }
            .foregroundStyle(.secondary)
        }
        .padding(12)
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 12))
        .padding(.horizontal)
        .transition(.move(edge: .top).combined(with: .opacity))
    }
}

#if DEBUG
#Preview {
    VStack {
        ErrorBannerView(
            message: "Failed to load reports",
            retryAction: { },
            dismissAction: { }
        )
        Spacer()
    }
    .sereneBloomBackground()
}
#endif
