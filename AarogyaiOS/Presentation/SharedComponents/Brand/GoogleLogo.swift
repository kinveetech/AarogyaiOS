import SwiftUI

/// The official 4-color Google "G" logo, matching the frontend's inline SVG.
struct GoogleLogo: View {
    var size: CGFloat = 20

    var body: some View {
        Canvas { context, _ in
            let scale = size / 24
            drawBlueSection(in: &context, scale: scale)
            drawGreenSection(in: &context, scale: scale)
            drawYellowSection(in: &context, scale: scale)
            drawRedSection(in: &context, scale: scale)
        }
        .frame(width: size, height: size)
    }
}

// MARK: - Drawing

private extension GoogleLogo {

    func drawBlueSection(in context: inout GraphicsContext, scale: CGFloat) {
        let path = Path { ref in
            ref.move(to: pt(22.56, 12.25, scale))
            ref.addCurve(to: pt(22.36, 10.0, scale),
                         control1: pt(22.56, 11.47, scale), control2: pt(22.49, 10.72, scale))
            ref.addLine(to: pt(12, 10.0, scale))
            ref.addLine(to: pt(12, 14.26, scale))
            ref.addLine(to: pt(17.92, 14.26, scale))
            ref.addCurve(to: pt(15.72, 17.58, scale),
                         control1: pt(17.49, 15.58, scale), control2: pt(16.78, 16.72, scale))
            ref.addLine(to: pt(19.29, 20.35, scale))
            ref.addCurve(to: pt(22.56, 12.25, scale),
                         control1: pt(21.37, 18.43, scale), control2: pt(22.56, 15.49, scale))
            ref.closeSubpath()
        }
        context.fill(path, with: .color(Color(hex: 0x4285F4)))
    }

    func drawGreenSection(in context: inout GraphicsContext, scale: CGFloat) {
        let path = Path { ref in
            ref.move(to: pt(12, 23, scale))
            ref.addCurve(to: pt(19.28, 20.34, scale),
                         control1: pt(14.97, 23, scale), control2: pt(17.46, 22.02, scale))
            ref.addLine(to: pt(15.71, 17.57, scale))
            ref.addCurve(to: pt(12, 18.63, scale),
                         control1: pt(14.73, 18.23, scale), control2: pt(13.48, 18.63, scale))
            ref.addCurve(to: pt(5.84, 14.1, scale),
                         control1: pt(9.14, 18.63, scale), control2: pt(6.71, 16.7, scale))
            ref.addLine(to: pt(2.18, 16.94, scale))
            ref.addCurve(to: pt(12, 23, scale),
                         control1: pt(3.99, 20.53, scale), control2: pt(7.7, 23, scale))
            ref.closeSubpath()
        }
        context.fill(path, with: .color(Color(hex: 0x34A853)))
    }

    func drawYellowSection(in context: inout GraphicsContext, scale: CGFloat) {
        let path = Path { ref in
            ref.move(to: pt(5.84, 14.09, scale))
            ref.addCurve(to: pt(5.49, 12, scale),
                         control1: pt(5.62, 13.43, scale), control2: pt(5.49, 12.73, scale))
            ref.addCurve(to: pt(5.84, 9.91, scale),
                         control1: pt(5.49, 11.27, scale), control2: pt(5.62, 10.57, scale))
            ref.addLine(to: pt(2.18, 7.07, scale))
            ref.addCurve(to: pt(1, 12, scale),
                         control1: pt(1.4, 8.55, scale), control2: pt(1, 10.23, scale))
            ref.addCurve(to: pt(2.18, 16.93, scale),
                         control1: pt(1, 13.77, scale), control2: pt(1.4, 15.45, scale))
            ref.addLine(to: pt(5.84, 14.09, scale))
            ref.closeSubpath()
        }
        context.fill(path, with: .color(Color(hex: 0xFBBC05)))
    }

    func drawRedSection(in context: inout GraphicsContext, scale: CGFloat) {
        let path = Path { ref in
            ref.move(to: pt(12, 5.38, scale))
            ref.addCurve(to: pt(16.21, 7.02, scale),
                         control1: pt(13.62, 5.38, scale), control2: pt(15.06, 5.94, scale))
            ref.addLine(to: pt(19.36, 3.87, scale))
            ref.addCurve(to: pt(12, 1, scale),
                         control1: pt(17.45, 2.09, scale), control2: pt(14.97, 1, scale))
            ref.addCurve(to: pt(2.18, 7.07, scale),
                         control1: pt(7.7, 1, scale), control2: pt(3.99, 3.47, scale))
            ref.addLine(to: pt(5.84, 9.91, scale))
            ref.addCurve(to: pt(12, 5.38, scale),
                         control1: pt(6.71, 7.31, scale), control2: pt(9.14, 5.38, scale))
            ref.closeSubpath()
        }
        context.fill(path, with: .color(Color(hex: 0xEA4335)))
    }

    func pt(_ xCoord: CGFloat, _ yCoord: CGFloat, _ scale: CGFloat) -> CGPoint {
        CGPoint(x: xCoord * scale, y: yCoord * scale)
    }
}

#if DEBUG
#Preview {
    HStack(spacing: 20) {
        GoogleLogo(size: 20)
        GoogleLogo(size: 40)
        GoogleLogo(size: 60)
    }
    .padding()
}
#endif
