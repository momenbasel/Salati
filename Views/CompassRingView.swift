import SwiftUI

// Named struct for cardinal directions — avoids ForEach tuple Identifiable issues.
private struct CardinalDirection: Identifiable {
    let id: String   // unique Arabic label used as identifier
    let angle: Double
    let label: String
}

private let cardinalDirections: [CardinalDirection] = [
    CardinalDirection(id: "N", angle:   0, label: "شمال"),
    CardinalDirection(id: "E", angle:  90, label: "شرق"),
    CardinalDirection(id: "S", angle: 180, label: "جنوب"),
    CardinalDirection(id: "W", angle: 270, label: "غرب"),
]

/// Rotating compass ring showing gold border, degree ticks, and Arabic cardinal labels.
/// The ring rotates by `-heading` so that geographic North always faces the top of the screen.
struct CompassRingView: View {
    /// Device heading in degrees (0 = true North, clockwise).
    var heading: Double

    // Layout constants
    private let ringDiameter: CGFloat  = 270
    private let tickOffset: CGFloat    = 122   // distance from center to outer tick edge
    private let labelOffset: CGFloat   = 92    // distance from center to label center

    var body: some View {
        ZStack {
            // ── Inner compass face ─────────────────────────────────────────
            Circle()
                .fill(
                    RadialGradient(
                        colors: [
                            Color(red: 15/255, green: 60/255, blue: 38/255),
                            Color(red:  8/255, green: 40/255, blue: 24/255),
                        ],
                        center: .center,
                        startRadius: 0,
                        endRadius: ringDiameter / 2
                    )
                )
                .frame(width: ringDiameter - 16, height: ringDiameter - 16)

            // ── Subtle inner glow ring ─────────────────────────────────────
            Circle()
                .stroke(QiblatiTheme.gold.opacity(0.18), lineWidth: 1)
                .frame(width: ringDiameter - 28, height: ringDiameter - 28)

            // ── Outer gold metallic ring ───────────────────────────────────
            Circle()
                .strokeBorder(
                    QiblatiTheme.goldAngularGradient,
                    lineWidth: 14
                )
                .frame(width: ringDiameter, height: ringDiameter)
                // Subtle drop shadow for depth
                .shadow(color: QiblatiTheme.darkGold.opacity(0.6), radius: 6, x: 0, y: 3)

            // ── Arabesque inner border line ────────────────────────────────
            Circle()
                .stroke(QiblatiTheme.gold.opacity(0.45), lineWidth: 0.8)
                .frame(width: ringDiameter - 14, height: ringDiameter - 14)

            // ── Tick marks every 30° ──────────────────────────────────────
            ForEach(0..<12) { i in
                let angle   = Double(i) * 30.0
                let isMajor = (i % 3 == 0)          // 0°, 90°, 180°, 270°

                Rectangle()
                    .fill(
                        isMajor
                            ? QiblatiTheme.gold.opacity(1.0)
                            : QiblatiTheme.gold.opacity(0.5)
                    )
                    .frame(
                        width:  isMajor ? 2.5 : 1.5,
                        height: isMajor ?  18 :  10
                    )
                    .offset(y: -tickOffset)
                    .rotationEffect(.degrees(angle))
            }

            // ── Degree number labels at 90° intervals ─────────────────────
            // Use trig to place each numeral at its correct angular position,
            // then counter-rotate by `heading` so the text stays upright
            // while the outer ZStack rotates by -heading.
            ForEach([0, 90, 180, 270], id: \.self) { deg in
                let rad = Double(deg) * .pi / 180.0
                let r   = labelOffset - 18
                Text("\(deg)°")
                    .font(.system(size: 9, weight: .light, design: .rounded))
                    .foregroundColor(QiblatiTheme.gold.opacity(0.55))
                    .fixedSize()
                    .offset(x: r * sin(rad), y: -r * cos(rad))
                    .rotationEffect(.degrees(heading))
            }

            // ── Arabic cardinal direction labels ──────────────────────────
            ForEach(cardinalDirections) { dir in
                let rad = dir.angle * .pi / 180.0
                Text(dir.label)
                    .font(QiblatiTheme.arabicBoldFont(size: 17))
                    .foregroundStyle(QiblatiTheme.goldGradient)
                    .fixedSize()
                    .offset(x: labelOffset * sin(rad), y: -labelOffset * cos(rad))
                    .rotationEffect(.degrees(heading))
            }
        }
        // Rotation is handled by the parent in CompassView (ring + Kaaba share one transform)
    }
}

#Preview {
    ZStack {
        Color(red: 13/255, green: 74/255, blue: 46/255).ignoresSafeArea()
        CompassRingView(heading: 45)
            .frame(width: 290, height: 290)
    }
}
