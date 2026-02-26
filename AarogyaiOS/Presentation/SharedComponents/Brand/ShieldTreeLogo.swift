import SwiftUI

/// The Aarogya Shield Tree logo — a teal gradient shield with a layered tree inside.
/// Matches the frontend's `shield-tree-logo.tsx` component exactly.
struct ShieldTreeLogo: View {
    var size: CGFloat = 80
    var showWordmark: Bool = true

    @Environment(\.colorScheme) private var colorScheme

    private var isDark: Bool { colorScheme == .dark }

    // MARK: - Theme-Adaptive Colors

    private var shieldGradientStart: Color {
        isDark ? Color(hex: 0x1A9E97) : Color(hex: 0x0E6B66)
    }

    private var shieldGradientEnd: Color {
        isDark ? Color(hex: 0x0E6B66) : Color(hex: 0x0A4D4A)
    }

    private var strokeColor: Color {
        isDark ? Color.white.opacity(0.4) : Color(hex: 0xFFF8F0)
    }

    private var rootOpacity: Double { isDark ? 0.15 : 0.25 }
    private var branchOpacity: Double { isDark ? 0.2 : 0.3 }

    // MARK: - Body

    var body: some View {
        VStack(spacing: 12) {
            Canvas { context, canvasSize in
                let scale = canvasSize.width / 80
                drawShield(in: &context, scale: scale)
                drawShieldHighlight(in: &context, scale: scale)
                drawTrunk(in: &context, scale: scale)
                drawRoots(in: &context, scale: scale)
                drawBranches(in: &context, scale: scale)
                drawCanopyBase(in: &context, scale: scale)
                drawCanopyLayers(in: &context, scale: scale)
                drawGroundGlow(in: &context, scale: scale)
            }
            .frame(width: size, height: size)

            if showWordmark {
                wordmark
            }
        }
    }

    private var wordmark: some View {
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
    }
}

// MARK: - Drawing Helpers

private extension ShieldTreeLogo {

    func drawShield(in context: inout GraphicsContext, scale: CGFloat) {
        let shieldPath = Path { path in
            path.move(to: pt(40, 4, scale))
            path.addCurve(to: pt(10, 10, scale), control1: pt(22, 4, scale), control2: pt(10, 10, scale))
            path.addLine(to: pt(10, 36, scale))
            path.addCurve(to: pt(40, 76, scale), control1: pt(10, 56, scale), control2: pt(24, 70, scale))
            path.addCurve(to: pt(70, 36, scale), control1: pt(56, 70, scale), control2: pt(70, 56, scale))
            path.addLine(to: pt(70, 10, scale))
            path.addCurve(to: pt(40, 4, scale), control1: pt(70, 10, scale), control2: pt(58, 4, scale))
            path.closeSubpath()
        }

        let gradient = Gradient(colors: [shieldGradientStart, shieldGradientEnd])
        context.opacity = 0.9
        context.fill(shieldPath, with: .linearGradient(
            gradient, startPoint: pt(20, 4, scale), endPoint: pt(60, 76, scale)
        ))
    }

    func drawShieldHighlight(in context: inout GraphicsContext, scale: CGFloat) {
        let innerPath = Path { path in
            path.move(to: pt(40, 10, scale))
            path.addCurve(to: pt(16, 14, scale), control1: pt(26, 10, scale), control2: pt(16, 14, scale))
            path.addLine(to: pt(16, 36, scale))
            path.addCurve(to: pt(40, 70, scale), control1: pt(16, 52, scale), control2: pt(27, 64, scale))
            path.addCurve(to: pt(64, 36, scale), control1: pt(53, 64, scale), control2: pt(64, 52, scale))
            path.addLine(to: pt(64, 14, scale))
            path.addCurve(to: pt(40, 10, scale), control1: pt(64, 14, scale), control2: pt(54, 10, scale))
            path.closeSubpath()
        }

        context.opacity = 1.0
        context.fill(innerPath, with: .color(.white.opacity(isDark ? 0.04 : 0.07)))
    }

    func drawTrunk(in context: inout GraphicsContext, scale: CGFloat) {
        let trunkPath = Path { path in
            path.move(to: pt(40, 66, scale))
            path.addLine(to: pt(40, 44, scale))
        }

        context.stroke(
            trunkPath,
            with: .color(strokeColor.opacity(0.5)),
            style: StrokeStyle(lineWidth: 3 * scale, lineCap: .round)
        )
    }

    func drawRoots(in context: inout GraphicsContext, scale: CGFloat) {
        strokeCurve(in: &context, scale: scale,
                    from: pt(40, 66), cp1: pt(36, 68), cp2: pt(30, 69), to: pt(28, 68),
                    width: 1.2, opacity: rootOpacity)
        strokeCurve(in: &context, scale: scale,
                    from: pt(40, 66), cp1: pt(44, 68), cp2: pt(50, 69), to: pt(52, 68),
                    width: 1.2, opacity: rootOpacity)
        strokeCurve(in: &context, scale: scale,
                    from: pt(40, 66), cp1: pt(38, 69), cp2: pt(36, 71), to: pt(34, 71),
                    width: 1.0, opacity: rootOpacity * 0.8)
        strokeCurve(in: &context, scale: scale,
                    from: pt(40, 66), cp1: pt(42, 69), cp2: pt(44, 71), to: pt(46, 71),
                    width: 1.0, opacity: rootOpacity * 0.8)
    }

    func drawBranches(in context: inout GraphicsContext, scale: CGFloat) {
        strokeCurve(in: &context, scale: scale,
                    from: pt(40, 48), cp1: pt(34, 44), cp2: pt(28, 42), to: pt(24, 42),
                    width: 1.5, opacity: branchOpacity)
        strokeCurve(in: &context, scale: scale,
                    from: pt(40, 48), cp1: pt(46, 44), cp2: pt(52, 42), to: pt(56, 42),
                    width: 1.5, opacity: branchOpacity)
        strokeCurve(in: &context, scale: scale,
                    from: pt(40, 44), cp1: pt(36, 40), cp2: pt(32, 36), to: pt(30, 34),
                    width: 1.2, opacity: branchOpacity * 0.85)
        strokeCurve(in: &context, scale: scale,
                    from: pt(40, 44), cp1: pt(44, 40), cp2: pt(48, 36), to: pt(50, 34),
                    width: 1.2, opacity: branchOpacity * 0.85)
    }

    func drawCanopyBase(in context: inout GraphicsContext, scale: CGFloat) {
        let canopy1 = ellipse(centerX: 40, centerY: 36, radiusX: 22, radiusY: 16, scale: scale)
        let canopyGradient: Gradient
        if isDark {
            canopyGradient = Gradient(colors: [
                Color(hex: 0xA8D5AE).opacity(0.5),
                Color(hex: 0x1A9E97).opacity(0.3)
            ])
            context.opacity = 0.5
        } else {
            canopyGradient = Gradient(colors: [
                Color(hex: 0xA8D5AE),
                Color(hex: 0x7FB285),
                Color(hex: 0x0E6B66)
            ])
            context.opacity = 0.45
        }
        context.fill(canopy1, with: .linearGradient(
            canopyGradient, startPoint: pt(24, 14, scale), endPoint: pt(56, 48, scale)
        ))
    }

    func drawCanopyLayers(in context: inout GraphicsContext, scale: CGFloat) {
        // Layer 2 — mid
        let canopy2 = ellipse(centerX: 40, centerY: 32, radiusX: 17, radiusY: 13, scale: scale)
        if isDark {
            context.opacity = 1.0
            context.fill(canopy2, with: .color(Color(hex: 0xA8D5AE).opacity(0.2)))
        } else {
            context.opacity = 0.4
            context.fill(canopy2, with: .color(Color(hex: 0x7FB285)))
        }

        // Layer 3 — small
        let canopy3 = ellipse(centerX: 40, centerY: 27, radiusX: 12, radiusY: 10, scale: scale)
        if isDark {
            context.opacity = 1.0
            context.fill(canopy3, with: .color(Color(hex: 0xA8D5AE).opacity(0.15)))
        } else {
            context.opacity = 0.35
            context.fill(canopy3, with: .color(Color(hex: 0xA8D5AE)))
        }

        // Layer 4 — crown highlight
        let canopy4 = ellipse(centerX: 40, centerY: 22, radiusX: 7, radiusY: 6, scale: scale)
        context.opacity = 1.0
        context.fill(canopy4, with: .color(.white.opacity(isDark ? 0.08 : 0.15)))
    }

    func drawGroundGlow(in context: inout GraphicsContext, scale: CGFloat) {
        let glow = ellipse(centerX: 40, centerY: 68, radiusX: 12, radiusY: 2.5, scale: scale)
        context.opacity = 1.0
        context.fill(glow, with: .color(Color(hex: 0xFFB347).opacity(isDark ? 0.25 : 0.3)))
    }

    // MARK: - Geometry Helpers

    func pt(_ xCoord: CGFloat, _ yCoord: CGFloat, _ scale: CGFloat) -> CGPoint {
        CGPoint(x: xCoord * scale, y: yCoord * scale)
    }

    func pt(_ xCoord: CGFloat, _ yCoord: CGFloat) -> CGPoint {
        CGPoint(x: xCoord, y: yCoord)
    }

    func ellipse(centerX: CGFloat, centerY: CGFloat, radiusX: CGFloat, radiusY: CGFloat, scale: CGFloat) -> Path {
        Path(ellipseIn: CGRect(
            x: (centerX - radiusX) * scale, y: (centerY - radiusY) * scale,
            width: radiusX * 2 * scale, height: radiusY * 2 * scale
        ))
    }

    // swiftlint:disable:next function_parameter_count
    func strokeCurve(
        in context: inout GraphicsContext,
        scale: CGFloat,
        from start: CGPoint,
        cp1: CGPoint,
        cp2: CGPoint,
        to end: CGPoint,
        width: CGFloat,
        opacity: Double
    ) {
        let curvePath = Path { path in
            path.move(to: pt(start.x, start.y, scale))
            path.addCurve(
                to: pt(end.x, end.y, scale),
                control1: pt(cp1.x, cp1.y, scale),
                control2: pt(cp2.x, cp2.y, scale)
            )
        }
        context.stroke(
            curvePath,
            with: .color(strokeColor.opacity(opacity)),
            style: StrokeStyle(lineWidth: width * scale, lineCap: .round)
        )
    }
}

#if DEBUG
#Preview("Light") {
    ShieldTreeLogo(size: 120)
        .padding()
        .sereneBloomBackground()
}

#Preview("Dark") {
    ShieldTreeLogo(size: 120)
        .padding()
        .sereneBloomBackground()
        .preferredColorScheme(.dark)
}

#Preview("Mark Only") {
    ShieldTreeLogo(size: 200, showWordmark: false)
        .padding()
        .sereneBloomBackground()
}
#endif
