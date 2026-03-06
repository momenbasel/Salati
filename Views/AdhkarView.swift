import SwiftUI

struct AdhkarView: View {
    @State private var selectedCategory: AdhkarData.Category = .morning
    @State private var showReminderSheet = false
    @AppStorage("appLanguage") private var lang: String = "ar"
    @AppStorage("morningAdhkarHour") private var morningHour: Int = 6
    @AppStorage("morningAdhkarMinute") private var morningMinute: Int = 0
    @AppStorage("eveningAdhkarHour") private var eveningHour: Int = 17
    @AppStorage("eveningAdhkarMinute") private var eveningMinute: Int = 0
    @AppStorage("morningReminderEnabled") private var morningReminderEnabled: Bool = false
    @AppStorage("eveningReminderEnabled") private var eveningReminderEnabled: Bool = false

    var body: some View {
        ZStack {
            RadialGradient(
                colors: [QiblatiTheme.primaryGreen, QiblatiTheme.secondaryGreen],
                center: .center, startRadius: 0, endRadius: 440
            )
            .ignoresSafeArea()

            IslamicPatternBackground(opacity: 0.05)
                .ignoresSafeArea()

            VStack(spacing: 0) {
                // Header with reminder button
                headerSection

                // Category picker
                categoryPicker

                // Adhkar list
                ScrollView {
                    LazyVStack(spacing: 12) {
                        ForEach(AdhkarData.adhkar(for: selectedCategory)) { dhikr in
                            DhikrCardView(dhikr: dhikr)
                        }
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 12)
                    .padding(.bottom, 20)
                }
            }
        }
        .sheet(isPresented: $showReminderSheet) {
            adhkarReminderSheet
        }
    }

    private var headerSection: some View {
        VStack(spacing: 4) {
            HStack {
                Button {
                    showReminderSheet = true
                } label: {
                    Image(systemName: "bell.badge.fill")
                        .font(.system(size: 20))
                        .foregroundColor(QiblatiTheme.gold)
                }

                Spacer()

                Text("الأذكار")
                    .font(QiblatiTheme.titleFont(size: 36))
                    .foregroundStyle(QiblatiTheme.goldGradient)

                Spacer()

                // Balance the layout
                Color.clear.frame(width: 20, height: 20)
            }
            .padding(.horizontal, 20)

            HStack(spacing: 8) {
                Rectangle().fill(QiblatiTheme.goldGradient).frame(height: 1)
                EightPointedStar().fill(QiblatiTheme.goldGradient).frame(width: 10, height: 10)
                Rectangle().fill(QiblatiTheme.goldGradient).frame(height: 1)
            }
            .padding(.horizontal, 40)
            .opacity(0.7)
        }
        .padding(.top, 16)
        .padding(.bottom, 8)
    }

    private func s(_ ar: String, _ en: String) -> String { lang == "en" ? en : ar }

    private var adhkarReminderSheet: some View {
        NavigationView {
            ZStack {
                QiblatiTheme.secondaryGreen.ignoresSafeArea()

                VStack(spacing: 24) {
                    // Morning reminder
                    VStack(spacing: 12) {
                        Toggle(isOn: $morningReminderEnabled) {
                            HStack {
                                Spacer()
                                VStack(alignment: .trailing) {
                                    Text(s("تذكير أذكار الصباح", "Morning Adhkar Reminder"))
                                        .font(QiblatiTheme.arabicBoldFont(size: 16))
                                        .foregroundColor(.white)
                                    Text(s("🌅 أذكار الصباح يومياً", "🌅 Daily morning adhkar"))
                                        .font(QiblatiTheme.arabicFont(size: 13))
                                        .foregroundColor(QiblatiTheme.gold.opacity(0.7))
                                }
                            }
                        }
                        .tint(QiblatiTheme.gold)
                        .onChange(of: morningReminderEnabled) { _, enabled in
                            if enabled {
                                PrayerNotificationManager.shared.requestPermission { granted in
                                    if granted {
                                        PrayerNotificationManager.shared.scheduleAdhkarReminder(
                                            hour: morningHour, minute: morningMinute, type: .morning
                                        )
                                    } else { morningReminderEnabled = false }
                                }
                            } else {
                                PrayerNotificationManager.shared.removeAdhkarReminder(type: .morning)
                            }
                        }

                        if morningReminderEnabled {
                            DatePicker("", selection: Binding(
                                get: {
                                    Calendar.current.date(from: DateComponents(hour: morningHour, minute: morningMinute)) ?? Date()
                                },
                                set: { newDate in
                                    let comps = Calendar.current.dateComponents([.hour, .minute], from: newDate)
                                    morningHour = comps.hour ?? 6
                                    morningMinute = comps.minute ?? 0
                                    PrayerNotificationManager.shared.scheduleAdhkarReminder(
                                        hour: morningHour, minute: morningMinute, type: .morning
                                    )
                                }
                            ), displayedComponents: .hourAndMinute)
                            .datePickerStyle(.wheel)
                            .labelsHidden()
                            .frame(height: 120)
                            .environment(\.locale, Locale(identifier: "ar"))
                        }
                    }
                    .padding(16)
                    .background(
                        RoundedRectangle(cornerRadius: 14)
                            .fill(QiblatiTheme.primaryGreen.opacity(0.5))
                            .overlay(
                                RoundedRectangle(cornerRadius: 14)
                                    .strokeBorder(QiblatiTheme.gold.opacity(0.15))
                            )
                    )

                    // Evening reminder
                    VStack(spacing: 12) {
                        Toggle(isOn: $eveningReminderEnabled) {
                            HStack {
                                Spacer()
                                VStack(alignment: .trailing) {
                                    Text(s("تذكير أذكار المساء", "Evening Adhkar Reminder"))
                                        .font(QiblatiTheme.arabicBoldFont(size: 16))
                                        .foregroundColor(.white)
                                    Text(s("🌙 أذكار المساء يومياً", "🌙 Daily evening adhkar"))
                                        .font(QiblatiTheme.arabicFont(size: 13))
                                        .foregroundColor(QiblatiTheme.gold.opacity(0.7))
                                }
                            }
                        }
                        .tint(QiblatiTheme.gold)
                        .onChange(of: eveningReminderEnabled) { _, enabled in
                            if enabled {
                                PrayerNotificationManager.shared.requestPermission { granted in
                                    if granted {
                                        PrayerNotificationManager.shared.scheduleAdhkarReminder(
                                            hour: eveningHour, minute: eveningMinute, type: .evening
                                        )
                                    } else { eveningReminderEnabled = false }
                                }
                            } else {
                                PrayerNotificationManager.shared.removeAdhkarReminder(type: .evening)
                            }
                        }

                        if eveningReminderEnabled {
                            DatePicker("", selection: Binding(
                                get: {
                                    Calendar.current.date(from: DateComponents(hour: eveningHour, minute: eveningMinute)) ?? Date()
                                },
                                set: { newDate in
                                    let comps = Calendar.current.dateComponents([.hour, .minute], from: newDate)
                                    eveningHour = comps.hour ?? 17
                                    eveningMinute = comps.minute ?? 0
                                    PrayerNotificationManager.shared.scheduleAdhkarReminder(
                                        hour: eveningHour, minute: eveningMinute, type: .evening
                                    )
                                }
                            ), displayedComponents: .hourAndMinute)
                            .datePickerStyle(.wheel)
                            .labelsHidden()
                            .frame(height: 120)
                            .environment(\.locale, Locale(identifier: "ar"))
                        }
                    }
                    .padding(16)
                    .background(
                        RoundedRectangle(cornerRadius: 14)
                            .fill(QiblatiTheme.primaryGreen.opacity(0.5))
                            .overlay(
                                RoundedRectangle(cornerRadius: 14)
                                    .strokeBorder(QiblatiTheme.gold.opacity(0.15))
                            )
                    )

                    Spacer()
                }
                .padding(20)
            }
            .navigationTitle(s("تذكير الأذكار", "Adhkar Reminders"))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button(s("تم", "Done")) { showReminderSheet = false }
                        .foregroundColor(QiblatiTheme.gold)
                }
            }
        }
        .presentationDetents([.medium])
    }

    private var categoryPicker: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 10) {
                ForEach(AdhkarData.Category.allCases) { category in
                    let isSelected = selectedCategory == category
                    Button {
                        withAnimation(.easeInOut(duration: 0.2)) {
                            selectedCategory = category
                        }
                    } label: {
                        HStack(spacing: 6) {
                            Image(systemName: category.icon)
                                .font(.system(size: 13))
                            Text(category.rawValue)
                                .font(QiblatiTheme.arabicFont(size: 13))
                        }
                        .padding(.horizontal, 14)
                        .padding(.vertical, 8)
                        .background(
                            Capsule()
                                .fill(isSelected ? QiblatiTheme.gold.opacity(0.25) : QiblatiTheme.secondaryGreen.opacity(0.6))
                        )
                        .overlay(
                            Capsule()
                                .strokeBorder(isSelected ? QiblatiTheme.gold.opacity(0.6) : QiblatiTheme.gold.opacity(0.2), lineWidth: 1)
                        )
                        .foregroundColor(isSelected ? QiblatiTheme.brightGold : QiblatiTheme.gold.opacity(0.7))
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
        }
    }
}

// MARK: - Dhikr Card

struct DhikrCardView: View {
    let dhikr: AdhkarData.Dhikr
    @State private var currentCount: Int = 0
    @State private var completed = false

    var body: some View {
        VStack(alignment: .trailing, spacing: 10) {
            // Dhikr text
            Text(dhikr.text)
                .font(QiblatiTheme.arabicFont(size: 20))
                .foregroundColor(.white)
                .multilineTextAlignment(.trailing)
                .lineSpacing(6)
                .frame(maxWidth: .infinity, alignment: .trailing)

            // Reference
            Text(dhikr.reference)
                .font(QiblatiTheme.arabicFont(size: 12))
                .foregroundColor(QiblatiTheme.gold.opacity(0.6))

            // Virtue
            if !dhikr.virtue.isEmpty {
                Text(dhikr.virtue)
                    .font(QiblatiTheme.arabicFont(size: 13))
                    .foregroundColor(QiblatiTheme.gold.opacity(0.8))
                    .multilineTextAlignment(.trailing)
                    .padding(.top, 2)
            }

            Divider().background(QiblatiTheme.gold.opacity(0.2))

            // Counter
            HStack {
                if dhikr.count > 1 {
                    // Counter button
                    Button {
                        if currentCount < dhikr.count {
                            currentCount += 1
                            #if os(iOS)
                            UIImpactFeedbackGenerator(style: .light).impactOccurred()
                            #endif
                            if currentCount >= dhikr.count {
                                completed = true
                                #if os(iOS)
                                UINotificationFeedbackGenerator().notificationOccurred(.success)
                                #endif
                            }
                        }
                    } label: {
                        HStack(spacing: 6) {
                            Image(systemName: completed ? "checkmark.circle.fill" : "plus.circle.fill")
                                .font(.system(size: 16))
                            let formatter = NumberFormatter()
                            let _ = formatter.locale = Locale(identifier: "ar")
                            let current = formatter.string(from: NSNumber(value: currentCount)) ?? "\(currentCount)"
                            let total = formatter.string(from: NSNumber(value: dhikr.count)) ?? "\(dhikr.count)"
                            Text("\(current) / \(total)")
                                .font(QiblatiTheme.arabicFont(size: 15))
                        }
                        .foregroundColor(completed ? .green : QiblatiTheme.gold)
                    }
                    .buttonStyle(.plain)
                    .disabled(completed)

                    Spacer()

                    // Reset
                    if currentCount > 0 {
                        Button {
                            currentCount = 0
                            completed = false
                        } label: {
                            Image(systemName: "arrow.counterclockwise")
                                .font(.system(size: 14))
                                .foregroundColor(QiblatiTheme.gold.opacity(0.5))
                        }
                        .buttonStyle(.plain)
                    }
                } else {
                    let formatter = NumberFormatter()
                    let _ = formatter.locale = Locale(identifier: "ar")
                    let countStr = formatter.string(from: NSNumber(value: dhikr.count)) ?? "\(dhikr.count)"
                    Text("مرة \(countStr)")
                        .font(QiblatiTheme.arabicFont(size: 13))
                        .foregroundColor(QiblatiTheme.gold.opacity(0.5))
                    Spacer()
                }
            }
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 14)
                .fill(QiblatiTheme.secondaryGreen.opacity(0.5))
                .overlay(
                    RoundedRectangle(cornerRadius: 14)
                        .strokeBorder(
                            completed ? Color.green.opacity(0.3) : QiblatiTheme.gold.opacity(0.15),
                            lineWidth: 1
                        )
                )
        )
    }
}
