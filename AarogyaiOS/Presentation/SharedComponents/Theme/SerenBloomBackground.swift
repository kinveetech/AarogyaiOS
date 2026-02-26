import SwiftUI

struct SereneBloomBackground: View {
    @Environment(\.colorScheme) private var colorScheme

    var body: some View {
        LinearGradient(
            stops: gradientStops,
            startPoint: UnitPoint(x: 0.25, y: 0),
            endPoint: UnitPoint(x: 0.75, y: 1)
        )
        .ignoresSafeArea()
    }

    private var gradientStops: [Gradient.Stop] {
        if colorScheme == .dark {
            [
                .init(color: Color(hex: 0x0B1A1A), location: 0.0),
                .init(color: Color(hex: 0x0F2020), location: 0.4),
                .init(color: Color(hex: 0x112626), location: 0.7),
                .init(color: Color(hex: 0x142B2B), location: 1.0)
            ]
        } else {
            [
                .init(color: Color(hex: 0xFFF8F0), location: 0.0),
                .init(color: Color(hex: 0xF0FAF0), location: 0.4),
                .init(color: Color(hex: 0xE0F5F0), location: 0.7),
                .init(color: Color(hex: 0xD5F0EA), location: 1.0)
            ]
        }
    }
}

extension View {
    func sereneBloomBackground() -> some View {
        background { SereneBloomBackground() }
    }
}
