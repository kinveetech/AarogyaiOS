import SwiftUI

extension Color {
    // MARK: - Brand

    static let brandPrimary = Color("BrandTeal", bundle: .main)
    static let brandPrimaryLight = Color("BrandPrimaryLight", bundle: .main)
    static let brandSecondary = Color("BrandSage", bundle: .main)
    static let brandAccent = Color("BrandAmber", bundle: .main)

    // MARK: - Backgrounds

    static let bgPrimary = Color("BackgroundPrimary", bundle: .main)
    static let bgSecondary = Color("BackgroundSecondary", bundle: .main)
    static let bgGradientStart = Color("BackgroundGradientStart", bundle: .main)
    static let bgGradientEnd = Color("BackgroundGradientEnd", bundle: .main)

    // MARK: - Text

    static let textPrimary = Color("TextPrimary", bundle: .main)
    static let textSecondary = Color("TextSecondary", bundle: .main)
    static let textTertiary = Color("TextTertiary", bundle: .main)

    // MARK: - Status

    static let statusNormal = Color("StatusNormal", bundle: .main)
    static let statusWarning = Color("StatusWarning", bundle: .main)
    static let statusCritical = Color("StatusCritical", bundle: .main)
    static let statusInfo = Color("StatusInfo", bundle: .main)

    // MARK: - Border

    static let borderDefault = Color("BorderDefault", bundle: .main)

    // MARK: - Hex Initializer

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

// MARK: - Fallback colors (hex values for use outside asset catalog)

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
