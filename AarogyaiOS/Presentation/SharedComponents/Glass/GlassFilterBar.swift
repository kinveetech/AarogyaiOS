import SwiftUI

struct GlassFilterBar<T: Hashable>: View {
    let items: [T]
    @Binding var selection: T?
    let allLabel: String
    let label: (T) -> String

    init(
        items: [T],
        selection: Binding<T?>,
        allLabel: String = "All",
        label: @escaping (T) -> String
    ) {
        self.items = items
        self._selection = selection
        self.allLabel = allLabel
        self.label = label
    }

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            GlassEffectContainer(spacing: 4) {
                HStack(spacing: 4) {
                    filterChip(label: allLabel, isSelected: selection == nil) {
                        withAnimation(.smooth) { selection = nil }
                    }

                    ForEach(items, id: \.self) { item in
                        filterChip(
                            label: label(item),
                            isSelected: selection == item
                        ) {
                            withAnimation(.smooth) { selection = item }
                        }
                    }
                }
                .padding(.horizontal, 16)
            }
        }
    }

    private func filterChip(
        label: String,
        isSelected: Bool,
        action: @escaping () -> Void
    ) -> some View {
        Button(action: action) {
            Text(label)
                .font(Typography.caption)
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
        }
        .glassEffect(
            isSelected
                ? .regular.tint(Color.Fallback.brandPrimary).interactive()
                : .regular.interactive(),
            in: .capsule
        )
    }
}

#if DEBUG
#Preview {
    @Previewable @State var selection: ReportType? = nil
    GlassFilterBar(
        items: ReportType.allCases,
        selection: $selection
    ) { type in
        type.rawValue.capitalized
    }
    .padding()
    .sereneBloomBackground()
}
#endif
