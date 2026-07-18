import SwiftUI

struct SettingsView: View {
    @AppStorage("hapticsEnabled") private var hapticsEnabled: Bool = true
    @AppStorage("hasSeenDedication") private var hasSeenDedication: Bool = true
    @AppStorage("appLanguage") private var appLanguage: String = "ar"
    @State private var showDedication = false

    private func s(_ ar: String, _ en: String) -> String { appLanguage == "en" ? en : ar }

    var body: some View {
        ZStack {
            QiblatiTheme.backgroundGradient
                .ignoresSafeArea()

            IslamicPatternBackground(opacity: 0.05)
                .ignoresSafeArea()

            ScrollView {
                VStack(spacing: 18) {
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
                .padding(.bottom, 100)
            }
            .overlay {
                if showDedication {
                    DedicationPopup(isPresented: $showDedication)
                }
            }
        }
    }

    private var headerSection: some View {
        VStack(spacing: 6) {
            Text(s("الإعدادات", "Settings"))
                .font(QiblatiTheme.titleFont(size: 36))
                .foregroundStyle(QiblatiTheme.goldGradient)

            OrnamentalDivider(width: 200)
        }
    }

    private var dedicationSection: some View {
        Button {
            showDedication = true
        } label: {
            HStack(spacing: 12) {
                ZStack {
                    Circle()
                        .fill(QiblatiTheme.gold.opacity(0.12))
                    Image(systemName: "heart.fill")
                        .font(.system(size: 14))
                        .foregroundStyle(QiblatiTheme.goldGradient)
                }
                .frame(width: 36, height: 36)

                Spacer()

                VStack(alignment: .trailing, spacing: 2) {
                    Text(s("الإهداء", "Dedication"))
                        .font(QiblatiTheme.arabicBoldFont(size: 16))
                        .foregroundColor(QiblatiTheme.ivory.opacity(0.95))
                    Text(s("صدقة جارية لروح حسنية ومحسن فوزي", "For the souls of Hasaneya & Mohsen Fawzy"))
                        .font(QiblatiTheme.arabicFont(size: 12))
                        .foregroundColor(QiblatiTheme.gold.opacity(0.6))
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 14)
        }
        .buttonStyle(.plain)
        .qiblatiCard(cornerRadius: 16)
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
                                .foregroundColor(appLanguage == "ar" ? QiblatiTheme.abyssGreen : QiblatiTheme.gold.opacity(0.6))
                                .padding(.horizontal, 16)
                                .padding(.vertical, 8)
                                .background(
                                    Capsule(style: .continuous)
                                        .fill(appLanguage == "ar" ? AnyShapeStyle(QiblatiTheme.goldGradient) : AnyShapeStyle(Color.clear))
                                )
                        }
                        .buttonStyle(.plain)

                        Button {
                            withAnimation(.easeInOut(duration: 0.2)) { appLanguage = "en" }
                        } label: {
                            Text("English")
                                .font(.system(size: 14, weight: .medium))
                                .foregroundColor(appLanguage == "en" ? QiblatiTheme.abyssGreen : QiblatiTheme.gold.opacity(0.6))
                                .padding(.horizontal, 16)
                                .padding(.vertical, 8)
                                .background(
                                    Capsule(style: .continuous)
                                        .fill(appLanguage == "en" ? AnyShapeStyle(QiblatiTheme.goldGradient) : AnyShapeStyle(Color.clear))
                                )
                        }
                        .buttonStyle(.plain)
                    }
                    .padding(3)
                    .background(
                        Capsule(style: .continuous)
                            .fill(QiblatiTheme.abyssGreen.opacity(0.5))
                            .overlay(
                                Capsule(style: .continuous)
                                    .strokeBorder(QiblatiTheme.hairline, lineWidth: 0.8)
                            )
                    )

                    Spacer()

                    Text(s("اللغة", "Language"))
                        .font(QiblatiTheme.arabicFont(size: 16))
                        .foregroundColor(QiblatiTheme.ivory.opacity(0.95))
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 12)

                Divider().background(QiblatiTheme.gold.opacity(0.1)).padding(.horizontal, 16)

                Toggle(isOn: $hapticsEnabled) {
                    HStack {
                        Spacer()
                        Text(s("الاهتزاز عند محاذاة القبلة", "Vibrate when facing Qibla"))
                            .font(QiblatiTheme.arabicFont(size: 16))
                            .foregroundColor(QiblatiTheme.ivory.opacity(0.95))
                    }
                }
                .tint(QiblatiTheme.gold)
                .padding(.horizontal, 16)
                .padding(.vertical, 12)
            }
            .qiblatiCard(cornerRadius: 16)
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
                            .foregroundColor(QiblatiTheme.ivory.opacity(0.85))
                        Text(s("صدقة جارية، نسأل الله القبول", "A sadaqah jariyah, may Allah accept it"))
                            .font(QiblatiTheme.arabicFont(size: 13))
                            .foregroundColor(QiblatiTheme.gold.opacity(0.6))
                    }
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 12)
            }
            .qiblatiCard(cornerRadius: 16)
        }
        .padding(.bottom, 30)
    }

    // MARK: - Helpers

    private func sectionTitle(_ text: String) -> some View {
        HStack(spacing: 8) {
            EightPointedStar()
                .fill(QiblatiTheme.goldVerticalGradient)
                .frame(width: 8, height: 8)
                .opacity(0.7)
            Text(text)
                .font(QiblatiTheme.arabicBoldFont(size: 16))
                .foregroundColor(QiblatiTheme.gold)
        }
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
                .foregroundColor(QiblatiTheme.ivory.opacity(0.85))
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
    }
}
