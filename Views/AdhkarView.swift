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
            QiblatiTheme.backgroundGradient
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
                    .padding(.bottom, 100)
                }
            }
        }
        .sheet(isPresented: $showReminderSheet) {
            adhkarReminderSheet
        }
    }

    private var headerSection: some View {
        VStack(spacing: 6) {
            HStack {
                Button {
                    showReminderSheet = true
                } label: {
                    ZStack {
                        Circle()
                            .fill(QiblatiTheme.gold.opacity(0.1))
                            .overlay(Circle().strokeBorder(QiblatiTheme.hairline, lineWidth: 0.8))
                        Image(systemName: "bell.badge.fill")
                            .font(.system(size: 15))
                            .foregroundStyle(QiblatiTheme.goldGradient)
                    }
                    .frame(width: 38, height: 38)
                }
                .buttonStyle(.plain)

                Spacer()

                Text("الأذكار")
                    .font(QiblatiTheme.titleFont(size: 36))
                    .foregroundStyle(QiblatiTheme.goldGradient)

                Spacer()

                // Balance the layout
                Color.clear.frame(width: 38, height: 38)
            }
            .padding(.horizontal, 20)

            OrnamentalDivider(width: 200)
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
                                        .foregroundColor(QiblatiTheme.ivory)
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
                    .qiblatiCard(cornerRadius: 16)

                    // Evening reminder
                    VStack(spacing: 12) {
                        Toggle(isOn: $eveningReminderEnabled) {
                            HStack {
                                Spacer()
                                VStack(alignment: .trailing) {
                                    Text(s("تذكير أذكار المساء", "Evening Adhkar Reminder"))
                                        .font(QiblatiTheme.arabicBoldFont(size: 16))
                                        .foregroundColor(QiblatiTheme.ivory)
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
                    .qiblatiCard(cornerRadius: 16)

                    Spacer()
                }
                .padding(20)
            }
            .navigationTitle(s("تذكير الأذكار", "Adhkar Reminders"))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button(s("تم", "Done")) { showReminderSheet = false }
                        .foregroundColor(QiblatiTheme.brightGold)
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
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.75)) {
                            selectedCategory = category
                        }
                        #if os(iOS)
                        UISelectionFeedbackGenerator().selectionChanged()
                        #endif
                    } label: {
                        HStack(spacing: 6) {
                            Image(systemName: category.icon)
                                .font(.system(size: 12, weight: .semibold))
                            Text(category.rawValue)
                                .font(QiblatiTheme.arabicFont(size: 13))
                        }
                        .padding(.horizontal, 14)
                        .padding(.vertical, 9)
                        .background(
                            Capsule(style: .continuous)
                                .fill(isSelected ? QiblatiTheme.goldGradient : LinearGradient(colors: [QiblatiTheme.surfaceGreen.opacity(0.7)], startPoint: .top, endPoint: .bottom))
                        )
                        .overlay(
                            Capsule(style: .continuous)
                                .strokeBorder(isSelected ? Color.clear : QiblatiTheme.hairline, lineWidth: 0.8)
                        )
                        .foregroundColor(isSelected ? QiblatiTheme.abyssGreen : QiblatiTheme.gold.opacity(0.75))
                        .shadow(color: isSelected ? QiblatiTheme.gold.opacity(0.35) : .clear, radius: 6, y: 2)
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
                .foregroundColor(QiblatiTheme.ivory)
                .multilineTextAlignment(.trailing)
                .lineSpacing(7)
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

            Divider().background(QiblatiTheme.gold.opacity(0.15))

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
                        HStack(spacing: 7) {
                            Image(systemName: completed ? "checkmark.circle.fill" : "plus.circle.fill")
                                .font(.system(size: 16))
                            let formatter = NumberFormatter()
                            let _ = formatter.locale = Locale(identifier: "ar")
                            let current = formatter.string(from: NSNumber(value: currentCount)) ?? "\(currentCount)"
                            let total = formatter.string(from: NSNumber(value: dhikr.count)) ?? "\(dhikr.count)"
                            Text("\(current) / \(total)")
                                .font(QiblatiTheme.arabicFont(size: 15))
                        }
                        .foregroundColor(completed ? QiblatiTheme.qiblaGreen : QiblatiTheme.brightGold)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(
                            Capsule(style: .continuous)
                                .fill((completed ? QiblatiTheme.qiblaGreen : QiblatiTheme.gold).opacity(0.1))
                                .overlay(
                                    Capsule(style: .continuous)
                                        .strokeBorder((completed ? QiblatiTheme.qiblaGreen : QiblatiTheme.gold).opacity(0.35), lineWidth: 0.8)
                                )
                        )
                    }
                    .buttonStyle(.plain)
                    .disabled(completed)

                    Spacer()

                    // Progress bar
                    GeometryReader { geo in
                        ZStack(alignment: .trailing) {
                            Capsule()
                                .fill(QiblatiTheme.gold.opacity(0.12))
                            Capsule()
                                .fill(completed ? AnyShapeStyle(QiblatiTheme.qiblaGreen) : AnyShapeStyle(QiblatiTheme.goldGradient))
                                .frame(width: geo.size.width * progress)
                        }
                    }
                    .frame(width: 90, height: 5)

                    // Reset
                    if currentCount > 0 && !completed {
                        Button {
                            currentCount = 0
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
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(QiblatiTheme.surfaceGradient)
                .overlay(
                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                        .strokeBorder(
                            completed ? QiblatiTheme.qiblaGreen.opacity(0.45) : QiblatiTheme.hairline,
                            lineWidth: completed ? 1.2 : 0.8
                        )
                )
                .shadow(color: Color.black.opacity(0.3), radius: 10, x: 0, y: 6)
        )
        .animation(.easeInOut(duration: 0.3), value: completed)
    }

    private var progress: CGFloat {
        guard dhikr.count > 0 else { return 0 }
        return min(CGFloat(currentCount) / CGFloat(dhikr.count), 1.0)
    }
}
