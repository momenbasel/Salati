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
                // Glow circle
                Circle()
                    .fill(isOnQibla ? Color.green.opacity(0.2) : QiblatiTheme.gold.opacity(0.1))
                    .frame(width: 40, height: 40)
                    .shadow(color: isOnQibla ? .green.opacity(0.7) : QiblatiTheme.gold.opacity(0.3), radius: isOnQibla ? 14 : 5)

                // Kaaba body
                ZStack {
                    RoundedRectangle(cornerRadius: 2)
                        .fill(QiblatiTheme.goldGradient)
                        .frame(width: 24, height: 28)

                    Rectangle()
                        .fill(Color.black.opacity(0.3))
                        .frame(width: 24, height: 6)
                        .offset(y: -6)

                    Rectangle()
                        .fill(QiblatiTheme.brightGold)
                        .frame(width: 20, height: 1.5)
                        .offset(y: -4)

                    RoundedRectangle(cornerRadius: 1.5)
                        .fill(Color.black.opacity(0.4))
                        .frame(width: 8, height: 10)
                        .offset(y: 6)

                    RoundedRectangle(cornerRadius: 1.5)
                        .stroke(QiblatiTheme.brightGold.opacity(0.7), lineWidth: 0.8)
                        .frame(width: 8, height: 10)
                        .offset(y: 6)
                }
                .shadow(color: isOnQibla ? .green.opacity(0.8) : QiblatiTheme.gold.opacity(0.4), radius: isOnQibla ? 16 : 5)

                // Green ring when aligned
                if isOnQibla {
                    Circle()
                        .stroke(Color.green.opacity(0.6), lineWidth: 2)
                        .frame(width: 40, height: 40)
                        .shadow(color: .green.opacity(0.7), radius: 8)
                }
            }
            .offset(y: -ringRadius)
        }
        .animation(.easeInOut(duration: 0.4), value: isOnQibla)
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
