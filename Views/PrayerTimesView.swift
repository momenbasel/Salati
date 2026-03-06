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

    private let timer = Timer.publish(every: 30, on: .main, in: .common).autoconnect()

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

                    if let times = prayerService.prayerTimes {
                        // Next prayer highlight
                        if let next = times.nextPrayer() {
                            nextPrayerCard(name: next.name, time: next.time)
                        }

                        // All prayer times
                        prayerListSection(times: times)

                        // Hijri date from API
                        if !times.hijriDate.isEmpty {
                            Text(times.hijriDate)
                                .font(QiblatiTheme.arabicFont(size: 16))
                                .foregroundColor(QiblatiTheme.gold.opacity(0.8))
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
                .padding(.bottom, 60)
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
        VStack(spacing: 4) {
            Text(s("مواقيت الصلاة", "Prayer Times"))
                .font(QiblatiTheme.titleFont(size: 36))
                .foregroundStyle(QiblatiTheme.goldGradient)

            HStack(spacing: 8) {
                Rectangle().fill(QiblatiTheme.goldGradient).frame(height: 1)
                EightPointedStar().fill(QiblatiTheme.goldGradient).frame(width: 10, height: 10)
                Rectangle().fill(QiblatiTheme.goldGradient).frame(height: 1)
            }
            .padding(.horizontal, 40)
            .opacity(0.7)

            Text(formattedDate())
                .font(QiblatiTheme.arabicFont(size: 14))
                .foregroundColor(QiblatiTheme.gold.opacity(0.7))
        }
    }

    private func nextPrayerCard(name: String, time: Date) -> some View {
        VStack(spacing: 8) {
            Text(s("الصلاة القادمة", "Next Prayer"))
                .font(QiblatiTheme.arabicFont(size: 13))
                .foregroundColor(QiblatiTheme.gold.opacity(0.7))

            Text(name)
                .font(QiblatiTheme.titleFont(size: 32))
                .foregroundStyle(QiblatiTheme.goldGradient)

            Text(formatTime(time))
                .font(QiblatiTheme.arabicBoldFont(size: 28))
                .foregroundColor(.white)

            Text(countdownText(to: time))
                .font(QiblatiTheme.arabicFont(size: 16))
                .foregroundColor(QiblatiTheme.gold.opacity(0.8))
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 20)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(QiblatiTheme.secondaryGreen.opacity(0.6))
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .strokeBorder(QiblatiTheme.gold.opacity(0.3), lineWidth: 1)
                )
        )
    }

    private func prayerListSection(times: PrayerTimesService.PrayerTimes) -> some View {
        VStack(spacing: 2) {
            ForEach(Array(times.all.enumerated()), id: \.offset) { index, prayer in
                let isNext = times.nextPrayer()?.name == prayer.name
                let isPassed = prayer.time <= currentTime

                HStack {
                    Image(systemName: prayer.icon)
                        .font(.system(size: 18))
                        .foregroundColor(isNext ? .white : QiblatiTheme.gold.opacity(isPassed ? 0.4 : 0.8))
                        .frame(width: 30)

                    Text(prayer.name)
                        .font(QiblatiTheme.arabicBoldFont(size: 18))
                        .foregroundColor(isNext ? .white : (isPassed ? QiblatiTheme.gold.opacity(0.4) : QiblatiTheme.gold))

                    Spacer()

                    Text(formatTime(prayer.time))
                        .font(QiblatiTheme.arabicFont(size: 18))
                        .foregroundColor(isNext ? .white : (isPassed ? QiblatiTheme.gold.opacity(0.4) : .white.opacity(0.9)))
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 14)
                .background(
                    RoundedRectangle(cornerRadius: 10)
                        .fill(isNext ? QiblatiTheme.gold.opacity(0.2) : Color.clear)
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .strokeBorder(isNext ? QiblatiTheme.gold.opacity(0.4) : Color.clear, lineWidth: 1)
                )

                if index < times.all.count - 1 {
                    Divider()
                        .background(QiblatiTheme.gold.opacity(0.15))
                        .padding(.horizontal, 16)
                }
            }
        }
        .background(
            RoundedRectangle(cornerRadius: 14)
                .fill(QiblatiTheme.secondaryGreen.opacity(0.4))
        )
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
                    .foregroundColor(QiblatiTheme.gold)
                    .padding(.horizontal, 20)
                    .padding(.vertical, 8)
                    .background(
                        RoundedRectangle(cornerRadius: 8)
                            .strokeBorder(QiblatiTheme.gold.opacity(0.3))
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
                HStack {
                    Spacer()
                    VStack(alignment: .trailing, spacing: 2) {
                        Text(s("تنبيهات مواقيت الصلاة", "Prayer Time Notifications"))
                            .font(QiblatiTheme.arabicFont(size: 16))
                            .foregroundColor(.white.opacity(0.9))
                        Text(s("إشعار عند دخول وقت كل صلاة", "Notify when each prayer time begins"))
                            .font(QiblatiTheme.arabicFont(size: 12))
                            .foregroundColor(QiblatiTheme.gold.opacity(0.6))
                    }
                }
            }
            .tint(QiblatiTheme.gold)
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
        }
        .background(
            RoundedRectangle(cornerRadius: 14)
                .fill(QiblatiTheme.secondaryGreen.opacity(0.4))
                .overlay(
                    RoundedRectangle(cornerRadius: 14)
                        .strokeBorder(QiblatiTheme.gold.opacity(0.15), lineWidth: 1)
                )
        )
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
