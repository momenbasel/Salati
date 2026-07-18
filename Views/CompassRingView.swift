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

/// Rotating compass ring showing gold bezel, fine degree ticks, and Arabic cardinal labels.
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
            // ── Inner compass face — layered enamel ────────────────────────
            Circle()
                .fill(
                    RadialGradient(
                        colors: [
                            Color(red: 22/255, green: 96/255, blue: 60/255),
                            Color(red: 13/255, green: 62/255, blue: 39/255),
                            Color(red:  6/255, green: 30/255, blue: 19/255),
                        ],
                        center: .center,
                        startRadius: 0,
                        endRadius: ringDiameter / 2
                    )
                )
                .frame(width: ringDiameter - 16, height: ringDiameter - 16)

            // ── Engraved concentric rings ─────────────────────────────────
            Circle()
                .stroke(QiblatiTheme.gold.opacity(0.10), lineWidth: 1)
                .frame(width: ringDiameter - 62, height: ringDiameter - 62)

            Circle()
                .stroke(QiblatiTheme.gold.opacity(0.07), lineWidth: 0.6)
                .frame(width: ringDiameter - 108, height: ringDiameter - 108)

            // ── Subtle inner glow ring ─────────────────────────────────────
            Circle()
                .stroke(QiblatiTheme.gold.opacity(0.2), lineWidth: 1)
                .frame(width: ringDiameter - 28, height: ringDiameter - 28)

            // ── Outer brushed-gold bezel ──────────────────────────────────
            Circle()
                .strokeBorder(
                    QiblatiTheme.goldAngularGradient,
                    lineWidth: 14
                )
                .frame(width: ringDiameter, height: ringDiameter)
                .shadow(color: QiblatiTheme.darkGold.opacity(0.65), radius: 8, x: 0, y: 4)
                .shadow(color: QiblatiTheme.paleGold.opacity(0.25), radius: 3, x: 0, y: -1)

            // Bezel highlight arcs (specular sheen)
            Circle()
                .trim(from: 0.06, to: 0.24)
                .stroke(QiblatiTheme.paleGold.opacity(0.55), style: StrokeStyle(lineWidth: 3, lineCap: .round))
                .frame(width: ringDiameter, height: ringDiameter)
            Circle()
                .trim(from: 0.56, to: 0.66)
                .stroke(QiblatiTheme.paleGold.opacity(0.28), style: StrokeStyle(lineWidth: 2, lineCap: .round))
                .frame(width: ringDiameter, height: ringDiameter)

            // ── Arabesque inner border line ────────────────────────────────
            Circle()
                .stroke(QiblatiTheme.gold.opacity(0.5), lineWidth: 0.8)
                .frame(width: ringDiameter - 14, height: ringDiameter - 14)

            // ── Fine ticks every 10°, medium every 30°, cardinal every 90° ─
            ForEach(0..<36) { i in
                let angle      = Double(i) * 10.0
                let isCardinal = (i % 9 == 0)          // 0°, 90°, 180°, 270°
                let isMajor    = (i % 3 == 0)          // every 30°

                Capsule()
                    .fill(
                        isCardinal
                            ? QiblatiTheme.paleGold.opacity(1.0)
                            : QiblatiTheme.gold.opacity(isMajor ? 0.7 : 0.3)
                    )
                    .frame(
                        width:  isCardinal ? 3 : (isMajor ? 2 : 1),
                        height: isCardinal ? 20 : (isMajor ? 13 : 7)
                    )
                    .offset(y: -tickOffset + (isCardinal ? 0 : 3))
                    .rotationEffect(.degrees(angle))
            }

            // ── Degree number labels at 90° intervals ─────────────────────
            // Use trig to place each numeral at its correct angular position,
            // then counter-rotate by `heading` so the text stays upright
            // while the outer ZStack rotates by -heading.
            ForEach([0, 90, 180, 270], id: \.self) { deg in
                let rad = Double(deg) * .pi / 180.0
                let r   = labelOffset - 22
                Text("\(deg)°")
                    .font(.system(size: 9, weight: .light, design: .rounded))
                    .foregroundColor(QiblatiTheme.gold.opacity(0.5))
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
                    .shadow(color: QiblatiTheme.gold.opacity(0.3), radius: 3)
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
