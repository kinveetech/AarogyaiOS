import SwiftUI

struct OfflineBannerView: View {
    var body: some View {
        HStack(spacing: 8) {
            Image(systemName: "wifi.slash")
                .font(.caption)
            Text("You're offline. Showing cached data.")
                .font(Typography.caption)
        }
        .foregroundStyle(.white)
        .padding(.vertical, 6)
        .padding(.horizontal, 12)
        .frame(maxWidth: .infinity)
        .background(Color.Fallback.textSecondary)
    }
}

#if DEBUG
#Preview {
    VStack {
        OfflineBannerView()
        Spacer()
    }
}
#endif
