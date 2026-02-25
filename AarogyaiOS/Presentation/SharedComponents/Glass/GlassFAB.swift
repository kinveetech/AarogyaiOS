import SwiftUI

struct GlassFAB: View {
    let icon: String
    let tintColor: Color
    let action: () -> Void

    init(
        icon: String = "plus",
        tintColor: Color = Color.Fallback.brandPrimary,
        action: @escaping () -> Void
    ) {
        self.icon = icon
        self.tintColor = tintColor
        self.action = action
    }

    var body: some View {
        Button(action: action) {
            Image(systemName: icon)
                .font(.title2)
                .frame(width: 56, height: 56)
        }
        .glassEffect(.regular.tint(tintColor).interactive(), in: .circle)
    }
}

#if DEBUG
#Preview {
    ZStack(alignment: .bottomTrailing) {
        Color.clear
        GlassFAB { }
            .padding(24)
    }
    .sereneBloomBackground()
}
#endif
