import SwiftUI
import UIKit

struct LocationDeniedView: View {
    var body: some View {
        ZStack {
            // Same background as compass
            QiblatiTheme.backgroundGradient
                .ignoresSafeArea()

            IslamicPatternBackground(opacity: 0.07)
                .ignoresSafeArea()

            VStack(spacing: 30) {
                Spacer()

                // Islamic compass icon (gold circle with location slash)
                ZStack {
                    Circle()
                        .fill(QiblatiTheme.abyssGreen.opacity(0.6))
                        .frame(width: 120, height: 120)
                    Circle()
                        .strokeBorder(QiblatiTheme.goldGradient, lineWidth: 2.5)
                        .frame(width: 112, height: 112)
                    Image(systemName: "location.slash.fill")
                        .font(.system(size: 44))
                        .foregroundStyle(QiblatiTheme.goldGradient)
                }
                .shadow(color: QiblatiTheme.gold.opacity(0.2), radius: 18)

                // Title
                VStack(spacing: 8) {
                    Text("قبلتي")
                        .font(QiblatiTheme.titleFont(size: 42))
                        .foregroundStyle(QiblatiTheme.goldGradient)

                    OrnamentalDivider(width: 160)
                }

                // Message
                Text("يحتاج تطبيق قبلتي إلى موقعك\nلتحديد اتجاه القبلة")
                    .font(QiblatiTheme.arabicBoldFont(size: 20))
                    .foregroundColor(QiblatiTheme.ivory)
                    .multilineTextAlignment(.center)
                    .lineSpacing(8)

                Text("يُرجى تفعيل خدمات الموقع من الإعدادات")
                    .font(QiblatiTheme.arabicFont(size: 16))
                    .foregroundColor(QiblatiTheme.gold.opacity(0.8))
                    .multilineTextAlignment(.center)

                // Open Settings button
                Button(action: openSettings) {
                    Text("فتح الإعدادات")
                        .font(QiblatiTheme.arabicBoldFont(size: 18))
                        .foregroundColor(QiblatiTheme.abyssGreen)
                        .padding(.horizontal, 40)
                        .padding(.vertical, 14)
                        .background(
                            Capsule(style: .continuous)
                                .fill(QiblatiTheme.goldGradient)
                                .shadow(color: QiblatiTheme.gold.opacity(0.35), radius: 10, y: 4)
                        )
                }
                .buttonStyle(.plain)

                Spacer()
            }
            .padding()
        }
    }

    private func openSettings() {
        if let url = URL(string: UIApplication.openSettingsURLString) {
            UIApplication.shared.open(url)
        }
    }
}

#Preview {
    LocationDeniedView()
}
