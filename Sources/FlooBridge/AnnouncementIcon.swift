import SwiftUI

enum AnnouncementIconState {
    case idle
    case selected
    case live
}

struct AnnouncementIcon: View {
    let state: AnnouncementIconState
    let color: Color

    var body: some View {
        ZStack {
            SpeakerShape()
                .fill(color)

            switch state {
            case .idle:
                EmptyView()

            case .selected:
                CheckMarkShape()
                    .stroke(color, style: StrokeStyle(lineWidth: 2.2, lineCap: .round, lineJoin: .round))

            case .live:
                WaveShape(scale: 0.82)
                    .stroke(color, style: StrokeStyle(lineWidth: 2.0, lineCap: .round, lineJoin: .round))
                WaveShape(scale: 1.18)
                    .stroke(color, style: StrokeStyle(lineWidth: 2.0, lineCap: .round, lineJoin: .round))
            }
        }
        .frame(width: 18, height: 18)
    }
}

private struct SpeakerShape: Shape {
    func path(in rect: CGRect) -> Path {
        let w = rect.width
        let h = rect.height

        var path = Path()
        path.move(to: CGPoint(x: 0.10 * w, y: 0.35 * h))
        path.addLine(to: CGPoint(x: 0.32 * w, y: 0.35 * h))
        path.addLine(to: CGPoint(x: 0.58 * w, y: 0.14 * h))
        path.addLine(to: CGPoint(x: 0.58 * w, y: 0.86 * h))
        path.addLine(to: CGPoint(x: 0.32 * w, y: 0.65 * h))
        path.addLine(to: CGPoint(x: 0.10 * w, y: 0.65 * h))
        path.closeSubpath()
        return path
    }
}

private struct CheckMarkShape: Shape {
    func path(in rect: CGRect) -> Path {
        let w = rect.width
        let h = rect.height

        var path = Path()
        path.move(to: CGPoint(x: 0.68 * w, y: 0.56 * h))
        path.addLine(to: CGPoint(x: 0.79 * w, y: 0.67 * h))
        path.addLine(to: CGPoint(x: 0.96 * w, y: 0.39 * h))
        return path
    }
}

private struct WaveShape: Shape {
    let scale: CGFloat

    func path(in rect: CGRect) -> Path {
        let w = rect.width
        let h = rect.height
        let center = CGPoint(x: 0.60 * w, y: 0.50 * h)
        let radius = 0.18 * w * scale

        var path = Path()
        path.addArc(
            center: center,
            radius: radius,
            startAngle: .degrees(-48),
            endAngle: .degrees(48),
            clockwise: false
        )
        return path.applying(
            CGAffineTransform(scaleX: 1.05, y: 1.25)
                .translatedBy(x: -0.03 * w, y: -0.10 * h)
        )
    }
}
