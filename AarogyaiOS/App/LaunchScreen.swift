import SwiftUI

/// Branded loading screen shown during auth-state check.
/// Animates the Shield Tree logo with a bloom sequence inspired
/// by the frontend's `shield-tree-loader.tsx`.
struct LaunchScreen: View {
    @State private var showLogo = false
    @State private var showWordmark = false
    @State private var showProgress = false
    @State private var rippleScale: CGFloat = 0.3
    @State private var rippleOpacity: Double = 0

    var body: some View {
        ZStack {
            SereneBloomBackground()

            VStack(spacing: 32) {
                Spacer()

                ZStack {
                    // Ripple rings
                    rippleRing(delay: 0, color: Color.Fallback.brandPrimary)
                    rippleRing(delay: 0.6, color: Color.Fallback.brandSecondary)
                    rippleRing(delay: 1.2, color: Color.Fallback.brandAccent)

                    // Logo with bloom animation
                    ShieldTreeLogo(size: 120, showWordmark: false)
                        .scaleEffect(showLogo ? 1.0 : 0.6)
                        .opacity(showLogo ? 1.0 : 0)
                }
                .frame(width: 200, height: 200)

                // Wordmark
                VStack(spacing: 4) {
                    Text("Aarogya")
                        .font(Typography.largeTitle)
                        .foregroundStyle(Color.textPrimary)

                    Text("Your Health, Our Priority")
                        .font(.system(size: 10, weight: .light))
                        .tracking(1.5)
                        .textCase(.uppercase)
                        .foregroundStyle(Color.textSecondary)
                }
                .opacity(showWordmark ? 1.0 : 0)
                .offset(y: showWordmark ? 0 : 16)

                Spacer()

                // Progress bar
                VStack(spacing: 12) {
                    ProgressView()
                        .tint(Color.Fallback.brandPrimary)
                    Text("Loading your health records…")
                        .font(Typography.caption)
                        .foregroundStyle(Color.textTertiary)
                }
                .opacity(showProgress ? 1.0 : 0)
                .padding(.bottom, 48)
            }
        }
        .task {
            withAnimation(.spring(response: 0.8, dampingFraction: 0.7)) {
                showLogo = true
            }
            try? await Task.sleep(for: .milliseconds(600))
            withAnimation(.easeOut(duration: 0.8)) {
                showWordmark = true
            }
            try? await Task.sleep(for: .milliseconds(400))
            withAnimation(.easeOut(duration: 0.6)) {
                showProgress = true
            }
        }
    }

    private func rippleRing(delay: Double, color: Color) -> some View {
        Circle()
            .strokeBorder(color.opacity(0.3), lineWidth: 1.5)
            .frame(width: 160, height: 160)
            .modifier(RippleModifier(delay: delay))
    }
}

/// Repeating ripple animation that expands and fades out.
private struct RippleModifier: ViewModifier {
    let delay: Double
    @State private var animate = false

    func body(content: Content) -> some View {
        content
            .scaleEffect(animate ? 2.0 : 0.3)
            .opacity(animate ? 0 : 0.7)
            .onAppear {
                withAnimation(
                    .easeOut(duration: 3.5)
                    .repeatForever(autoreverses: false)
                    .delay(1.0 + delay)
                ) {
                    animate = true
                }
            }
    }
}

#if DEBUG
#Preview("Light") {
    LaunchScreen()
}

#Preview("Dark") {
    LaunchScreen()
        .preferredColorScheme(.dark)
}
#endif
