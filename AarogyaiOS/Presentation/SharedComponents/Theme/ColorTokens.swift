import SwiftUI

extension Color {
    // MARK: - Brand

    static let brandPrimary = Color("brand.primary", bundle: .main)
    static let brandPrimaryLight = Color("brand.primaryLight", bundle: .main)
    static let brandSecondary = Color("brand.secondary", bundle: .main)
    static let brandAccent = Color("brand.accent", bundle: .main)

    // MARK: - Backgrounds

    static let bgPrimary = Color("bg.primary", bundle: .main)
    static let bgSecondary = Color("bg.secondary", bundle: .main)
    static let bgGradientStart = Color("bg.gradient.start", bundle: .main)
    static let bgGradientEnd = Color("bg.gradient.end", bundle: .main)

    // MARK: - Text

    static let textPrimary = Color("text.primary", bundle: .main)
    static let textSecondary = Color("text.secondary", bundle: .main)
    static let textTertiary = Color("text.tertiary", bundle: .main)

    // MARK: - Status

    static let statusNormal = Color("status.normal", bundle: .main)
    static let statusWarning = Color("status.warning", bundle: .main)
    static let statusCritical = Color("status.critical", bundle: .main)
    static let statusInfo = Color("status.info", bundle: .main)

    // MARK: - Border

    static let borderDefault = Color("border.default", bundle: .main)

    // MARK: - Hex Fallbacks

    init(hex: UInt, opacity: Double = 1.0) {
        self.init(
            .sRGB,
            red: Double((hex >> 16) & 0xFF) / 255,
            green: Double((hex >> 8) & 0xFF) / 255,
            blue: Double(hex & 0xFF) / 255,
            opacity: opacity
        )
    }
}

// MARK: - Fallback colors (used when asset catalog isn't configured yet)

extension Color {
    enum Fallback {
        static let brandPrimary = Color(hex: 0x0D9488)
        static let brandPrimaryLight = Color(hex: 0x5EEAD4)
        static let brandSecondary = Color(hex: 0x84CC16)
        static let brandAccent = Color(hex: 0xF59E0B)

        static let bgPrimary = Color(hex: 0xFAFAF5)
        static let bgSecondary = Color(hex: 0xF0F4F0)
        static let bgGradientStart = Color(hex: 0xFBF9F0)
        static let bgGradientEnd = Color(hex: 0xE8F0E8)

        static let textPrimary = Color(hex: 0x1A1A1A)
        static let textSecondary = Color(hex: 0x6B7280)
        static let textTertiary = Color(hex: 0x9CA3AF)

        static let statusNormal = Color(hex: 0x22C55E)
        static let statusWarning = Color(hex: 0xF59E0B)
        static let statusCritical = Color(hex: 0xEF4444)
        static let statusInfo = Color(hex: 0x3B82F6)

        static let borderDefault = Color(hex: 0xE5E7EB)
    }
}
