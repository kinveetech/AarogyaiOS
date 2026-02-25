import SwiftUI

enum Typography {
    // Headings — DM Serif Display
    static let largeTitle = Font.custom("DMSerifDisplay-Regular", size: 34, relativeTo: .largeTitle)
    static let title = Font.custom("DMSerifDisplay-Regular", size: 28, relativeTo: .title)
    static let title2 = Font.custom("DMSerifDisplay-Regular", size: 22, relativeTo: .title2)

    // Body — Outfit
    static let headline = Font.custom("Outfit-SemiBold", size: 17, relativeTo: .headline)
    static let body = Font.custom("Outfit-Regular", size: 17, relativeTo: .body)
    static let callout = Font.custom("Outfit-Regular", size: 16, relativeTo: .callout)
    static let subheadline = Font.custom("Outfit-Regular", size: 15, relativeTo: .subheadline)
    static let footnote = Font.custom("Outfit-Regular", size: 13, relativeTo: .footnote)
    static let caption = Font.custom("Outfit-Regular", size: 12, relativeTo: .caption)

    // Data — DM Mono
    static let data = Font.custom("DMMono-Medium", size: 15, relativeTo: .body)
    static let dataSmall = Font.custom("DMMono-Regular", size: 13, relativeTo: .footnote)
}

// MARK: - View Modifier

struct TypeStyle: ViewModifier {
    let font: Font

    func body(content: Content) -> some View {
        content.font(font)
    }
}

extension View {
    func typeStyle(_ font: Font) -> some View {
        modifier(TypeStyle(font: font))
    }
}
