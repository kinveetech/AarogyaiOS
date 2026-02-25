import SwiftUI

struct SereneBloomBackground: View {
    var body: some View {
        LinearGradient(
            colors: [Color.Fallback.bgGradientStart, Color.Fallback.bgGradientEnd],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
        .ignoresSafeArea()
    }
}

extension View {
    func sereneBloomBackground() -> some View {
        background { SereneBloomBackground() }
    }
}
