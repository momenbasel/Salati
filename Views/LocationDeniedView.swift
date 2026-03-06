import SwiftUI
import UIKit

struct LocationDeniedView: View {
    var body: some View {
        ZStack {
            // Same background as compass
            RadialGradient(
                colors: [
                    QiblatiTheme.primaryGreen,
                    QiblatiTheme.secondaryGreen
                ],
                center: .center,
                startRadius: 0,
                endRadius: 400
            )
            .ignoresSafeArea()

            IslamicPatternBackground(opacity: 0.07)
                .ignoresSafeArea()

            VStack(spacing: 32) {
                Spacer()

                // Islamic compass icon (gold circle with location slash)
                ZStack {
                    Circle()
                        .strokeBorder(QiblatiTheme.goldGradient, lineWidth: 3)
                        .frame(width: 100, height: 100)
                    Image(systemName: "location.slash.fill")
                        .font(.system(size: 44))
                        .foregroundStyle(QiblatiTheme.goldGradient)
                }

                // Title
                Text("قبلتي")
                    .font(QiblatiTheme.titleFont(size: 42))
                    .foregroundStyle(QiblatiTheme.goldGradient)

                // Message
                Text("يحتاج تطبيق قبلتي إلى موقعك\nلتحديد اتجاه القبلة")
                    .font(QiblatiTheme.arabicBoldFont(size: 20))
                    .foregroundColor(.white)
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
                        .foregroundStyle(QiblatiTheme.goldGradient)
                        .padding(.horizontal, 40)
                        .padding(.vertical, 14)
                        .background(
                            RoundedRectangle(cornerRadius: 14)
                                .stroke(QiblatiTheme.gold, lineWidth: 1.5)
                        )
                }

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
