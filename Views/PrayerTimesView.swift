import SwiftUI
import CoreLocation
import UserNotifications

struct PrayerTimesView: View {
    @ObservedObject var locationManager: LocationManager
    @StateObject private var prayerService = PrayerTimesService()
    @AppStorage("notificationsEnabled") private var notificationsEnabled: Bool = false
    @AppStorage("appLanguage") private var lang: String = "ar"

    private func s(_ ar: String, _ en: String) -> String { lang == "en" ? en : ar }

    @State private var currentTime = Date()
    @State private var showNotificationPrompt = false
    @State private var heroGlow = false

    private let timer = Timer.publish(every: 30, on: .main, in: .common).autoconnect()

    var body: some View {
        ZStack {
            QiblatiTheme.backgroundGradient
                .ignoresSafeArea()

            IslamicPatternBackground(opacity: 0.05)
                .ignoresSafeArea()

            ScrollView {
                VStack(spacing: 18) {
                    headerSection

                    if let times = prayerService.prayerTimes {
                        // Next prayer highlight
                        if let next = times.nextPrayer() {
                            nextPrayerCard(name: next.name, time: next.time)
                                .transition(.opacity.combined(with: .scale(scale: 0.96)))
                        }

                        // All prayer times
                        prayerListSection(times: times)

                        // Hijri date from API
                        if !times.hijriDate.isEmpty {
                            HStack(spacing: 8) {
                                Image(systemName: "moon.stars.fill")
                                    .font(.system(size: 12))
                                    .foregroundStyle(QiblatiTheme.goldGradient)
                                Text(times.hijriDate)
                                    .font(QiblatiTheme.arabicFont(size: 15))
                                    .foregroundColor(QiblatiTheme.gold.opacity(0.85))
                            }
                            .padding(.horizontal, 16)
                            .padding(.vertical, 8)
                            .background(
                                Capsule(style: .continuous)
                                    .fill(QiblatiTheme.abyssGreen.opacity(0.5))
                                    .overlay(
                                        Capsule(style: .continuous)
                                            .strokeBorder(QiblatiTheme.hairline, lineWidth: 0.8)
                                    )
                            )
                        }
                    } else if prayerService.isLoading {
                        loadingSection
                    } else if let error = prayerService.error {
                        errorSection(error)
                    } else {
                        loadingSection
                    }

                    // Notification toggle
                    notificationSection
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 16)
                .padding(.bottom, 110)
            }
        }
        .onAppear { fetchTimes() }
        .onReceive(timer) { _ in
            currentTime = Date()
        }
        .onChange(of: locationManager.location?.latitude) { _, _ in fetchTimes() }
        .onChange(of: prayerService.prayerTimes?.date) { _, _ in
            scheduleNotificationsIfEnabled()
        }
        .alert(s("تنبيهات الصلاة", "Prayer Alerts"), isPresented: $showNotificationPrompt) {
            Button(s("نعم، فعّل التنبيهات", "Enable Notifications")) {
                requestNotificationPermission()
            }
            Button(s("لاحقاً", "Later"), role: .cancel) {}
        } message: {
            Text(s("هل تريد تفعيل تنبيهات مواقيت الصلاة؟", "Enable prayer time notifications?"))
        }
    }

    // MARK: - Subviews

    private var headerSection: some View {
        VStack(spacing: 6) {
            Text(s("مواقيت الصلاة", "Prayer Times"))
                .font(QiblatiTheme.titleFont(size: 36))
                .foregroundStyle(QiblatiTheme.goldGradient)

            OrnamentalDivider(width: 200)

            Text(formattedDate())
                .font(QiblatiTheme.arabicFont(size: 14))
                .foregroundColor(QiblatiTheme.gold.opacity(0.7))
        }
    }

    private func nextPrayerCard(name: String, time: Date) -> some View {
        VStack(spacing: 10) {
            Text(s("الصلاة القادمة", "Next Prayer"))
                .font(QiblatiTheme.arabicFont(size: 13))
                .foregroundColor(QiblatiTheme.gold.opacity(0.65))

            Text(name)
                .font(QiblatiTheme.titleFont(size: 34))
                .foregroundStyle(QiblatiTheme.goldGradient)
                .goldShimmer()
                .shadow(color: QiblatiTheme.gold.opacity(0.35), radius: 8)

            Text(formatTime(time))
                .font(QiblatiTheme.arabicBoldFont(size: 30))
                .foregroundColor(QiblatiTheme.ivory)

            // Countdown pill
            HStack(spacing: 6) {
                Image(systemName: "hourglass")
                    .font(.system(size: 11))
                Text(countdownText(to: time))
                    .font(QiblatiTheme.arabicFont(size: 15))
            }
            .foregroundColor(QiblatiTheme.brightGold)
            .padding(.horizontal, 14)
            .padding(.vertical, 6)
            .background(
                Capsule(style: .continuous)
                    .fill(QiblatiTheme.gold.opacity(0.12))
                    .overlay(
                        Capsule(style: .continuous)
                            .strokeBorder(QiblatiTheme.gold.opacity(0.35), lineWidth: 0.8)
                    )
            )
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 24)
        .background(
            ZStack {
                RoundedRectangle(cornerRadius: 20, style: .continuous)
                    .fill(QiblatiTheme.surfaceGradient)

                RoundedRectangle(cornerRadius: 20, style: .continuous)
                    .strokeBorder(
                        QiblatiTheme.gold.opacity(heroGlow ? 0.55 : 0.25),
                        lineWidth: 1.2
                    )
                    .shadow(color: QiblatiTheme.gold.opacity(heroGlow ? 0.3 : 0.08), radius: heroGlow ? 14 : 6)
                    .animation(.easeInOut(duration: 2.2).repeatForever(autoreverses: true), value: heroGlow)
                    .onAppear { heroGlow = true }

                RoundedRectangle(cornerRadius: 20, style: .continuous)
                    .strokeBorder(QiblatiTheme.gold.opacity(0.15), lineWidth: 0.6)
                    .padding(5)
            }
            .shadow(color: Color.black.opacity(0.4), radius: 16, x: 0, y: 10)
        )
    }

    private func prayerListSection(times: PrayerTimesService.PrayerTimes) -> some View {
        VStack(spacing: 0) {
            ForEach(Array(times.all.enumerated()), id: \.offset) { index, prayer in
                let isNext = times.nextPrayer()?.name == prayer.name
                let isPassed = prayer.time <= currentTime

                HStack(spacing: 12) {
                    // Icon medallion
                    ZStack {
                        Circle()
                            .fill(isNext ? QiblatiTheme.gold.opacity(0.25) : QiblatiTheme.gold.opacity(isPassed ? 0.05 : 0.1))
                        Image(systemName: prayer.icon)
                            .font(.system(size: 14))
                            .foregroundColor(isNext ? QiblatiTheme.paleGold : QiblatiTheme.gold.opacity(isPassed ? 0.35 : 0.75))
                    }
                    .frame(width: 34, height: 34)

                    Text(prayer.name)
                        .font(QiblatiTheme.arabicBoldFont(size: 18))
                        .foregroundColor(isNext ? QiblatiTheme.ivory : (isPassed ? QiblatiTheme.gold.opacity(0.35) : QiblatiTheme.gold))

                    if isNext {
                        Text(s("القادمة", "Next"))
                            .font(QiblatiTheme.arabicFont(size: 11))
                            .foregroundColor(QiblatiTheme.abyssGreen)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 3)
                            .background(Capsule().fill(QiblatiTheme.goldGradient))
                    }

                    Spacer()

                    Text(formatTime(prayer.time))
                        .font(QiblatiTheme.arabicFont(size: 18))
                        .foregroundColor(isNext ? QiblatiTheme.ivory : (isPassed ? QiblatiTheme.gold.opacity(0.35) : QiblatiTheme.ivory.opacity(0.9)))
                }
                .padding(.horizontal, 14)
                .padding(.vertical, 12)
                .background(
                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                        .fill(isNext ? QiblatiTheme.gold.opacity(0.12) : Color.clear)
                )

                if index < times.all.count - 1 {
                    Divider()
                        .background(QiblatiTheme.gold.opacity(0.12))
                        .padding(.horizontal, 16)
                }
            }
        }
        .padding(.vertical, 6)
        .qiblatiCard(cornerRadius: 18)
    }

    private var loadingSection: some View {
        VStack(spacing: 12) {
            ProgressView()
                .tint(QiblatiTheme.gold)
            Text(s("جارٍ تحميل المواقيت...", "Loading prayer times..."))
                .font(QiblatiTheme.arabicFont(size: 15))
                .foregroundColor(QiblatiTheme.gold.opacity(0.7))
        }
        .padding(.vertical, 40)
    }

    private func errorSection(_ error: String) -> some View {
        VStack(spacing: 12) {
            Image(systemName: "wifi.slash")
                .font(.system(size: 30))
                .foregroundColor(QiblatiTheme.gold.opacity(0.5))
            Text(error)
                .font(QiblatiTheme.arabicFont(size: 15))
                .foregroundColor(QiblatiTheme.gold.opacity(0.7))
            Button {
                fetchTimes()
            } label: {
                Text(s("إعادة المحاولة", "Retry"))
                    .font(QiblatiTheme.arabicFont(size: 14))
                    .foregroundColor(QiblatiTheme.brightGold)
                    .padding(.horizontal, 22)
                    .padding(.vertical, 9)
                    .background(
                        Capsule(style: .continuous)
                            .strokeBorder(QiblatiTheme.gold.opacity(0.4), lineWidth: 1)
                    )
            }
        }
        .padding(.vertical, 40)
    }

    private var notificationSection: some View {
        VStack(spacing: 0) {
            Toggle(isOn: Binding(
                get: { notificationsEnabled },
                set: { newValue in
                    if newValue {
                        showNotificationPrompt = true
                    } else {
                        notificationsEnabled = false
                        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
                    }
                }
            )) {
                HStack(spacing: 12) {
                    ZStack {
                        Circle()
                            .fill(QiblatiTheme.gold.opacity(notificationsEnabled ? 0.2 : 0.08))
                        Image(systemName: notificationsEnabled ? "bell.fill" : "bell")
                            .font(.system(size: 14))
                            .foregroundColor(QiblatiTheme.gold.opacity(notificationsEnabled ? 1 : 0.6))
                    }
                    .frame(width: 34, height: 34)

                    Spacer()

                    VStack(alignment: .trailing, spacing: 2) {
                        Text(s("تنبيهات مواقيت الصلاة", "Prayer Time Notifications"))
                            .font(QiblatiTheme.arabicFont(size: 16))
                            .foregroundColor(QiblatiTheme.ivory.opacity(0.95))
                        Text(s("إشعار عند دخول وقت كل صلاة", "Notify when each prayer time begins"))
                            .font(QiblatiTheme.arabicFont(size: 12))
                            .foregroundColor(QiblatiTheme.gold.opacity(0.6))
                    }
                }
            }
            .tint(QiblatiTheme.gold)
            .padding(.horizontal, 16)
            .padding(.vertical, 14)
        }
        .qiblatiCard(cornerRadius: 18)
    }

    // MARK: - Helpers

    private func fetchTimes() {
        guard let coord = locationManager.location else { return }
        prayerService.fetchPrayerTimes(for: coord)
    }

    private func requestNotificationPermission() {
        PrayerNotificationManager.shared.requestPermission { granted in
            notificationsEnabled = granted
            if granted {
                scheduleNotificationsIfEnabled()
            }
        }
    }

    private func scheduleNotificationsIfEnabled() {
        guard notificationsEnabled, let times = prayerService.prayerTimes else { return }
        PrayerNotificationManager.shared.schedulePrayerNotifications(times: times)
    }

    private func formatTime(_ date: Date) -> String {
        let f = DateFormatter()
        f.dateFormat = "h:mm a"
        f.locale = Locale(identifier: "ar")
        return f.string(from: date)
    }

    private func formattedDate() -> String {
        let f = DateFormatter()
        f.dateStyle = .long
        f.locale = Locale(identifier: "ar")
        return f.string(from: Date())
    }

    private func countdownText(to date: Date) -> String {
        let diff = date.timeIntervalSince(currentTime)
        guard diff > 0 else { return s("حان الآن", "Now") }
        let hours = Int(diff) / 3600
        let minutes = (Int(diff) % 3600) / 60
        let formatter = NumberFormatter()
        formatter.locale = Locale(identifier: lang == "en" ? "en" : "ar")
        let h = formatter.string(from: NSNumber(value: hours)) ?? "\(hours)"
        let m = formatter.string(from: NSNumber(value: minutes)) ?? "\(minutes)"
        if hours > 0 {
            return lang == "en" ? "\(h)h \(m)m remaining" : "متبقي \(h) ساعة و \(m) دقيقة"
        } else {
            return lang == "en" ? "\(m) min remaining" : "متبقي \(m) دقيقة"
        }
    }
}
