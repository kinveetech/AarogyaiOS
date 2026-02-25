import SwiftUI

struct SereneBloomBackground: View {
    @Environment(\.colorScheme) private var colorScheme

    var body: some View {
        LinearGradient(
            colors: gradientColors,
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
        .ignoresSafeArea()
    }

    private var gradientColors: [Color] {
        if colorScheme == .dark {
            [Color(hex: 0x0C1917), Color(hex: 0x132624)]
        } else {
            [Color(hex: 0xFBF9F0), Color(hex: 0xE8F0E8)]
        }
    }
}

extension View {
    func sereneBloomBackground() -> some View {
        background { SereneBloomBackground() }
    }
}
