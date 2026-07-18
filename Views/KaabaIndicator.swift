import SwiftUI

/// The Kaaba icon sitting at a fixed position on the compass ring edge.
/// Position it by rotating with `qiblaBearing` — it never moves on its own.
struct KaabaIndicator: View {
    var isOnQibla: Bool = false

    private let ringRadius: CGFloat = 125

    var body: some View {
        ZStack {
            // Kaaba icon pinned to ring edge
            ZStack {
                // Halo
                Circle()
                    .fill(
                        RadialGradient(
                            colors: [
                                (isOnQibla ? QiblatiTheme.qiblaGreen : QiblatiTheme.gold).opacity(isOnQibla ? 0.4 : 0.22),
                                .clear,
                            ],
                            center: .center,
                            startRadius: 2,
                            endRadius: 26
                        )
                    )
                    .frame(width: 52, height: 52)

                // Kaaba body — kiswa black with gold band
                VStack(spacing: 0) {
                    ZStack {
                        // Cube
                        RoundedRectangle(cornerRadius: 2.5, style: .continuous)
                            .fill(
                                LinearGradient(
                                    colors: [
                                        Color(red: 0.16, green: 0.16, blue: 0.17),
                                        Color(red: 0.05, green: 0.05, blue: 0.06),
                                    ],
                                    startPoint: .top,
                                    endPoint: .bottom
                                )
                            )
                            .frame(width: 24, height: 26)
                            .overlay(
                                RoundedRectangle(cornerRadius: 2.5, style: .continuous)
                                    .strokeBorder(QiblatiTheme.gold.opacity(0.5), lineWidth: 0.6)
                            )

                        // Gold band (hizam)
                        Rectangle()
                            .fill(QiblatiTheme.goldGradient)
                            .frame(width: 24, height: 4.5)
                            .offset(y: -5)

                        // Door
                        RoundedRectangle(cornerRadius: 1.2, style: .continuous)
                            .fill(QiblatiTheme.goldVerticalGradient)
                            .frame(width: 5, height: 9)
                            .offset(x: 6, y: 4.5)
                    }

                    // Pedestal
                    Trapezoid()
                        .fill(QiblatiTheme.goldVerticalGradient)
                        .frame(width: 30, height: 5)
                }
                .shadow(color: isOnQibla ? QiblatiTheme.qiblaGreen.opacity(0.8) : .black.opacity(0.6),
                        radius: isOnQibla ? 12 : 4, y: 2)

                // Green alignment ring
                if isOnQibla {
                    Circle()
                        .stroke(QiblatiTheme.qiblaGreen.opacity(0.7), lineWidth: 1.8)
                        .frame(width: 46, height: 46)
                        .shadow(color: QiblatiTheme.qiblaGreen.opacity(0.7), radius: 8)
                }
            }
            .offset(y: -ringRadius)
        }
        .animation(.easeInOut(duration: 0.4), value: isOnQibla)
    }
}

/// Slightly tapered base under the Kaaba cube.
private struct Trapezoid: Shape {
    func path(in rect: CGRect) -> Path {
        Path { p in
            p.move(to: CGPoint(x: rect.minX + 4, y: rect.minY))
            p.addLine(to: CGPoint(x: rect.maxX - 4, y: rect.minY))
            p.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY))
            p.addLine(to: CGPoint(x: rect.minX, y: rect.maxY))
            p.closeSubpath()
        }
    }
}

/// Upward-pointing triangle for arrow heads — used by both KaabaIndicator and heading needle.
struct QiblaArrowHead: Shape {
    func path(in rect: CGRect) -> Path {
        Path { p in
            p.move(to: CGPoint(x: rect.midX, y: rect.minY))
            p.addLine(to: CGPoint(x: rect.minX, y: rect.maxY))
            p.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY))
            p.closeSubpath()
        }
    }
}

#Preview {
    ZStack {
        Color(red: 13/255, green: 74/255, blue: 46/255).ignoresSafeArea()
        HStack(spacing: 60) {
            ZStack {
                Circle().stroke(Color.gray.opacity(0.3), lineWidth: 1).frame(width: 250, height: 250)
                KaabaIndicator(isOnQibla: false).rotationEffect(.degrees(135))
            }
            ZStack {
                Circle().stroke(Color.green.opacity(0.3), lineWidth: 1).frame(width: 250, height: 250)
                KaabaIndicator(isOnQibla: true).rotationEffect(.degrees(135))
            }
        }
    }
}
