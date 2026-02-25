import SwiftUI

struct LaunchScreen: View {
    var body: some View {
        ZStack {
            LinearGradient(
                colors: [
                    Color.Fallback.bgGradientStart,
                    Color.Fallback.bgGradientEnd
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()

            Image(systemName: "heart.text.clipboard")
                .font(.system(size: 80, weight: .light))
                .foregroundStyle(Color.Fallback.brandPrimary)
        }
    }
}
