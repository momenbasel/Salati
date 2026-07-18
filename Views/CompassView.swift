import SwiftUI
import CoreLocation

/// Main compass screen for the Qiblati iOS app.
struct CompassView: View {
    @ObservedObject var locationManager: LocationManager
    @StateObject private var hapticWrapper = HapticManagerWrapper()
    @AppStorage("appLanguage") private var lang: String = "ar"

    // Entrance animations
    @State private var appeared = false
    @State private var titleAppeared = false

    // Pulse ring animation
    @State private var isPulsing = false

    // Ambient breathing halo
    @State private var haloBreathing = false

    var body: some View {
        ZStack {
            // ── Background: deep emerald radial gradient ───────────────────
            QiblatiTheme.backgroundGradient
                .ignoresSafeArea()

            // ── Tessellated Islamic pattern overlay ────────────────────────
            IslamicPatternBackground(opacity: 0.07)
                .ignoresSafeArea()

            VStack(spacing: 0) {
                // ── Title ──────────────────────────────────────────────────
                titleSection

                Spacer()

                // ── Compass ────────────────────────────────────────────────
                compassSection

                Spacer()

                // ── Distance / status ──────────────────────────────────────
                bottomSection
            }
            .padding(.horizontal, 24)
            .padding(.vertical, 20)
        }
        .onAppear {
            locationManager.requestPermission()
        }
        .onChange(of: locationManager.isOnQibla) { _, newValue in
            hapticWrapper.update(isOnQibla: newValue)
        }
    }

    // MARK: - Subviews

    private var titleSection: some View {
        VStack(spacing: 6) {
            Text("صلاتي")
                .font(QiblatiTheme.titleFont(size: 52))
                .foregroundStyle(QiblatiTheme.goldGradient)
                .goldShimmer()
                .shadow(color: QiblatiTheme.gold.opacity(0.55), radius: 10, x: 0, y: 2)
                .offset(y: titleAppeared ? 0 : -30)
                .opacity(titleAppeared ? 1.0 : 0)
                .onAppear {
                    withAnimation(.easeOut(duration: 0.5).delay(0.2)) {
                        titleAppeared = true
                    }
                }

            OrnamentalDivider(width: 200)
        }
        .padding(.top, 8)
    }

    private var compassSection: some View {
        ZStack {
            // ── Ambient breathing halo ─────────────────────────────────────
            Circle()
                .fill(
                    RadialGradient(
                        colors: [
                            (locationManager.isOnQibla ? QiblatiTheme.qiblaGreen : QiblatiTheme.gold).opacity(haloBreathing ? 0.22 : 0.1),
                            .clear,
                        ],
                        center: .center,
                        startRadius: 90,
                        endRadius: 210
                    )
                )
                .frame(width: 420, height: 420)
                .animation(.easeInOut(duration: 2.4).repeatForever(autoreverses: true), value: haloBreathing)
                .animation(.easeInOut(duration: 0.6), value: locationManager.isOnQibla)
                .onAppear { haloBreathing = true }

            // ── Static ring: N always at top, never rotates ───────────────
            CompassRingView(heading: 0)
                .frame(width: 290, height: 290)

            // ── Kaaba FIXED at geographic Qibla bearing (never moves) ─────
            KaabaIndicator(isOnQibla: locationManager.isOnQibla)
                .rotationEffect(.degrees(locationManager.qiblaBearing), anchor: .center)

            // ── Heading needle: rotates with device, points where you face ─
            // When needle aligns with Kaaba icon = you're facing Qibla
            headingNeedle

            // ── "On Qibla" alignment pulse ring ───────────────────────────
            if locationManager.isOnQibla {
                Circle()
                    .stroke(QiblatiTheme.qiblaGreen.opacity(0.35), lineWidth: 3)
                    .frame(width: 280, height: 280)
                    .scaleEffect(isPulsing ? 1.1 : 1.0)
                    .opacity(isPulsing ? 0.0 : 0.6)
                    .animation(.easeOut(duration: 1.2).repeatForever(autoreverses: false), value: isPulsing)
                    .onAppear { isPulsing = true }
                    .onDisappear { isPulsing = false }
            }
        }
        .frame(width: 310, height: 310)
        .scaleEffect(appeared ? 1.0 : 0.8)
        .opacity(appeared ? 1.0 : 0)
        .onAppear {
            withAnimation(.spring(response: 0.6, dampingFraction: 0.7)) {
                appeared = true
            }
        }
    }

    /// The rotating needle that shows the current device heading.
    private var headingNeedle: some View {
        let isGreen = locationManager.isOnQibla
        let arrowGradient = LinearGradient(
            colors: isGreen
                ? [QiblatiTheme.qiblaGreen, QiblatiTheme.qiblaGreen.opacity(0.7)]
                : [Color(red: 0.92, green: 0.28, blue: 0.25), Color(red: 0.72, green: 0.15, blue: 0.15)],
            startPoint: .top, endPoint: .bottom
        )
        return ZStack {
            // Arrow tip + shaft (VStack offset so bottom of shaft = compass center)
            VStack(spacing: 0) {
                QiblaArrowHead()
                    .fill(arrowGradient)
                    .frame(width: 22, height: 18)
                    .shadow(color: isGreen ? QiblatiTheme.qiblaGreen.opacity(0.7) : .red.opacity(0.4),
                            radius: isGreen ? 10 : 4)
                Capsule()
                    .fill(arrowGradient)
                    .frame(width: 4.5, height: 78)
                    .shadow(color: isGreen ? QiblatiTheme.qiblaGreen.opacity(0.35) : .red.opacity(0.2), radius: 3)
            }
            .offset(y: -(78 + 18) / 2)  // bottom of shaft sits at y=0 (center)

            // Center jewel
            ZStack {
                Circle()
                    .fill(QiblatiTheme.goldVerticalGradient)
                    .frame(width: 16, height: 16)
                    .shadow(color: QiblatiTheme.gold.opacity(0.5), radius: 4)
                Circle()
                    .fill(isGreen ? QiblatiTheme.qiblaGreen : Color(red: 0.92, green: 0.28, blue: 0.25))
                    .frame(width: 7, height: 7)
            }

            // Gold counterweight tail (opposite direction)
            VStack(spacing: 0) {
                Capsule()
                    .fill(LinearGradient(
                        colors: [QiblatiTheme.gold.opacity(0.7), QiblatiTheme.gold.opacity(0.05)],
                        startPoint: .top, endPoint: .bottom
                    ))
                    .frame(width: 2.5, height: 52)
                EightPointedStar()
                    .fill(QiblatiTheme.goldGradient)
                    .frame(width: 9, height: 9)
                    .opacity(0.8)
            }
            .offset(y: 30)
        }
        .rotationEffect(.degrees(locationManager.heading), anchor: .center)
        .animation(.easeOut(duration: 0.15), value: locationManager.heading)
        .animation(.easeInOut(duration: 0.4), value: locationManager.isOnQibla)
    }

    private func s(_ ar: String, _ en: String) -> String { lang == "en" ? en : ar }

    /// Directional guidance text
    private var directionGuidanceText: String {
        let angle = locationManager.qiblaDirection
        let absAngle = abs(angle)
        if absAngle <= 3 { return s("أنت تتجه نحو القبلة", "Facing the Qibla") }
        if absAngle <= 15 { return angle > 0 ? s("أدر قليلاً لليمين ←", "Turn slightly right ←") : s("أدر قليلاً لليسار →", "Turn slightly left →") }
        if absAngle <= 90 { return angle > 0 ? s("أدر لليمين ←", "Turn right ←") : s("أدر لليسار →", "Turn left →") }
        return s("القبلة خلفك ↺", "Qibla is behind you ↺")
    }

    private var directionGuidanceColor: Color {
        let absAngle = abs(locationManager.qiblaDirection)
        if absAngle <= 3 { return QiblatiTheme.qiblaGreen }
        if absAngle <= 15 { return .orange }
        return QiblatiTheme.gold.opacity(0.75)
    }

    private var bottomSection: some View {
        VStack(spacing: 10) {
            if locationManager.authorizationStatus == .denied
                || locationManager.authorizationStatus == .restricted {
                Text(s("يرجى تفعيل خدمات الموقع في الإعدادات", "Please enable location services in Settings"))
                    .font(QiblatiTheme.arabicFont(size: 15))
                    .foregroundColor(QiblatiTheme.gold.opacity(0.8))
                    .multilineTextAlignment(.center)
            } else if !locationManager.isHeadingAvailable {
                Text(s("البوصلة غير متاحة على هذا الجهاز", "Compass not available on this device"))
                    .font(QiblatiTheme.arabicFont(size: 15))
                    .foregroundColor(QiblatiTheme.gold.opacity(0.8))
                    .multilineTextAlignment(.center)
            } else if locationManager.distanceToKaaba > 0 {
                // Alignment celebration
                if locationManager.isOnQibla {
                    Text("اللَّهُ أَكْبَرُ")
                        .font(QiblatiTheme.titleFont(size: 28))
                        .foregroundColor(QiblatiTheme.qiblaGreen)
                        .shadow(color: QiblatiTheme.qiblaGreen.opacity(0.6), radius: 8)
                        .transition(.opacity.combined(with: .scale(scale: 0.8)))
                }

                // Directional guidance
                Text(directionGuidanceText)
                    .font(QiblatiTheme.arabicBoldFont(size: 16))
                    .foregroundColor(directionGuidanceColor)
                    .multilineTextAlignment(.center)
                    .id(directionGuidanceText)

                // Distance panel
                HStack(spacing: 10) {
                    Image(systemName: "mappin.and.ellipse")
                        .font(.system(size: 13))
                        .foregroundStyle(QiblatiTheme.goldGradient)

                    Text(s("المسافة إلى مكة المكرمة", "Distance to Mecca"))
                        .font(QiblatiTheme.arabicFont(size: 13))
                        .foregroundColor(QiblatiTheme.gold.opacity(0.6))

                    Text(QiblaCalculator.formattedDistance(locationManager.distanceToKaaba))
                        .font(QiblatiTheme.arabicBoldFont(size: 16))
                        .foregroundStyle(QiblatiTheme.goldGradient)
                }
                .padding(.horizontal, 18)
                .padding(.vertical, 10)
                .background(
                    Capsule(style: .continuous)
                        .fill(QiblatiTheme.abyssGreen.opacity(0.55))
                        .overlay(
                            Capsule(style: .continuous)
                                .strokeBorder(QiblatiTheme.hairline, lineWidth: 0.8)
                        )
                )
            } else {
                HStack(spacing: 8) {
                    ProgressView()
                        .tint(QiblatiTheme.gold)
                    Text(s("جارٍ تحديد موقعك...", "Locating you..."))
                        .font(QiblatiTheme.arabicFont(size: 15))
                        .foregroundColor(QiblatiTheme.gold.opacity(0.7))
                }
            }
        }
        .animation(.easeInOut(duration: 0.4), value: locationManager.isOnQibla)
        .animation(.easeInOut(duration: 0.3), value: directionGuidanceText)
        .animation(.easeIn(duration: 0.5), value: locationManager.distanceToKaaba > 0)
        .padding(.bottom, 90)
    }
}

// MARK: - HapticManagerWrapper

/// @MainActor ObservableObject wrapper so HapticManager can be used as a @StateObject.
@MainActor
final class HapticManagerWrapper: ObservableObject {
    private let haptics = HapticManager()

    func update(isOnQibla: Bool) {
        haptics.update(isOnQibla: isOnQibla)
    }
}

// MARK: - Preview

#Preview {
    let lm = LocationManager()
    return CompassView(locationManager: lm)
}
