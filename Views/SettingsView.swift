import SwiftUI

struct SettingsView: View {
    @AppStorage("hapticsEnabled") private var hapticsEnabled: Bool = true
    @AppStorage("hasSeenDedication") private var hasSeenDedication: Bool = true
    @AppStorage("appLanguage") private var appLanguage: String = "ar"
    @State private var showDedication = false

    private func s(_ ar: String, _ en: String) -> String { appLanguage == "en" ? en : ar }

    var body: some View {
        ZStack {
            RadialGradient(
                colors: [QiblatiTheme.primaryGreen, QiblatiTheme.secondaryGreen],
                center: .center, startRadius: 0, endRadius: 440
            )
            .ignoresSafeArea()

            IslamicPatternBackground(opacity: 0.05)
                .ignoresSafeArea()

            ScrollView {
                VStack(spacing: 20) {
                    headerSection

                    // Dedication (moved up)
                    dedicationSection

                    // Preferences
                    preferencesSection

                    // About
                    aboutSection
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 16)
            }
            .overlay {
                if showDedication {
                    DedicationPopup(isPresented: $showDedication)
                }
            }
        }
    }

    private var headerSection: some View {
        VStack(spacing: 4) {
            Text(s("الإعدادات", "Settings"))
                .font(QiblatiTheme.titleFont(size: 36))
                .foregroundStyle(QiblatiTheme.goldGradient)

            HStack(spacing: 8) {
                Rectangle().fill(QiblatiTheme.goldGradient).frame(height: 1)
                EightPointedStar().fill(QiblatiTheme.goldGradient).frame(width: 10, height: 10)
                Rectangle().fill(QiblatiTheme.goldGradient).frame(height: 1)
            }
            .padding(.horizontal, 40)
            .opacity(0.7)
        }
    }

    private var dedicationSection: some View {
        Button {
            showDedication = true
        } label: {
            HStack {
                Image(systemName: "heart.fill")
                    .foregroundColor(QiblatiTheme.gold)
                Spacer()
                Text(s("عرض الإهداء", "View Dedication"))
                    .font(QiblatiTheme.arabicFont(size: 16))
                    .foregroundColor(QiblatiTheme.gold)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 14)
            .background(
                RoundedRectangle(cornerRadius: 14)
                    .fill(QiblatiTheme.secondaryGreen.opacity(0.5))
                    .overlay(
                        RoundedRectangle(cornerRadius: 14)
                            .strokeBorder(QiblatiTheme.gold.opacity(0.2), lineWidth: 1)
                    )
            )
        }
        .buttonStyle(.plain)
    }

    private var preferencesSection: some View {
        VStack(alignment: .trailing, spacing: 12) {
            sectionTitle(s("التفضيلات", "Preferences"))

            VStack(spacing: 0) {
                // Language toggle
                HStack {
                    // Language buttons
                    HStack(spacing: 0) {
                        Button {
                            withAnimation(.easeInOut(duration: 0.2)) { appLanguage = "ar" }
                        } label: {
                            Text("عربي")
                                .font(QiblatiTheme.arabicFont(size: 14))
                                .foregroundColor(appLanguage == "ar" ? .white : QiblatiTheme.gold.opacity(0.6))
                                .padding(.horizontal, 16)
                                .padding(.vertical, 8)
                                .background(
                                    RoundedRectangle(cornerRadius: 8)
                                        .fill(appLanguage == "ar" ? QiblatiTheme.gold.opacity(0.3) : Color.clear)
                                )
                        }
                        .buttonStyle(.plain)

                        Button {
                            withAnimation(.easeInOut(duration: 0.2)) { appLanguage = "en" }
                        } label: {
                            Text("English")
                                .font(.system(size: 14, weight: .medium))
                                .foregroundColor(appLanguage == "en" ? .white : QiblatiTheme.gold.opacity(0.6))
                                .padding(.horizontal, 16)
                                .padding(.vertical, 8)
                                .background(
                                    RoundedRectangle(cornerRadius: 8)
                                        .fill(appLanguage == "en" ? QiblatiTheme.gold.opacity(0.3) : Color.clear)
                                )
                        }
                        .buttonStyle(.plain)
                    }
                    .background(
                        RoundedRectangle(cornerRadius: 8)
                            .strokeBorder(QiblatiTheme.gold.opacity(0.2))
                    )

                    Spacer()

                    Text(s("اللغة", "Language"))
                        .font(QiblatiTheme.arabicFont(size: 16))
                        .foregroundColor(.white.opacity(0.9))
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 12)

                Divider().background(QiblatiTheme.gold.opacity(0.1)).padding(.horizontal, 16)

                Toggle(isOn: $hapticsEnabled) {
                    HStack {
                        Spacer()
                        Text(s("الاهتزاز عند محاذاة القبلة", "Vibrate when facing Qibla"))
                            .font(QiblatiTheme.arabicFont(size: 16))
                            .foregroundColor(.white.opacity(0.9))
                    }
                }
                .tint(QiblatiTheme.gold)
                .padding(.horizontal, 16)
                .padding(.vertical, 12)
            }
            .background(
                RoundedRectangle(cornerRadius: 14)
                    .fill(QiblatiTheme.secondaryGreen.opacity(0.5))
                    .overlay(
                        RoundedRectangle(cornerRadius: 14)
                            .strokeBorder(QiblatiTheme.gold.opacity(0.15), lineWidth: 1)
                    )
            )
        }
    }

    private var aboutSection: some View {
        VStack(alignment: .trailing, spacing: 12) {
            sectionTitle(s("عن التطبيق", "About"))

            VStack(spacing: 0) {
                infoRow(label: s("الإصدار", "Version"), value: "١.١")
                Divider().background(QiblatiTheme.gold.opacity(0.1)).padding(.horizontal, 16)
                infoRow(label: s("المطوّر", "Developer"), value: "Moamen Basel")
                Divider().background(QiblatiTheme.gold.opacity(0.1)).padding(.horizontal, 16)

                HStack {
                    Spacer()
                    VStack(alignment: .trailing, spacing: 4) {
                        Text(s("تطبيق مجاني بلا إعلانات", "Free app, no ads"))
                            .font(QiblatiTheme.arabicFont(size: 15))
                            .foregroundColor(.white.opacity(0.8))
                        Text(s("صدقة جارية، نسأل الله القبول", "A sadaqah jariyah, may Allah accept it"))
                            .font(QiblatiTheme.arabicFont(size: 13))
                            .foregroundColor(QiblatiTheme.gold.opacity(0.6))
                    }
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 12)
            }
            .background(
                RoundedRectangle(cornerRadius: 14)
                    .fill(QiblatiTheme.secondaryGreen.opacity(0.5))
                    .overlay(
                        RoundedRectangle(cornerRadius: 14)
                            .strokeBorder(QiblatiTheme.gold.opacity(0.15), lineWidth: 1)
                    )
            )
        }
        .padding(.bottom, 30)
    }

    // MARK: - Helpers

    private func sectionTitle(_ text: String) -> some View {
        Text(text)
            .font(QiblatiTheme.arabicBoldFont(size: 16))
            .foregroundColor(QiblatiTheme.gold)
            .frame(maxWidth: .infinity, alignment: .trailing)
    }

    private func infoRow(label: String, value: String) -> some View {
        HStack {
            Text(value)
                .font(QiblatiTheme.arabicFont(size: 15))
                .foregroundColor(QiblatiTheme.gold.opacity(0.8))
            Spacer()
            Text(label)
                .font(QiblatiTheme.arabicFont(size: 15))
                .foregroundColor(.white.opacity(0.8))
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
    }
}
