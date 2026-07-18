import SwiftUI

struct TasbeehView: View {
    // Preset dhikr options
    private let presets: [(text: String, target: Int)] = [
        ("سُبْحَانَ اللَّهِ", 33),
        ("الْحَمْدُ لِلَّهِ", 33),
        ("اللَّهُ أَكْبَرُ", 33),
        ("لَا إِلَهَ إِلَّا اللَّهُ", 100),
        ("أَسْتَغْفِرُ اللَّهَ", 100),
        ("سُبْحَانَ اللَّهِ وَبِحَمْدِهِ", 100),
        ("لَا حَوْلَ وَلَا قُوَّةَ إِلَّا بِاللَّهِ", 100),
        ("اللَّهُمَّ صَلِّ عَلَى مُحَمَّدٍ", 100),
    ]

    @State private var selectedPreset: Int = 0
    @State private var count: Int = 0
    @State private var totalToday: Int = 0
    @State private var showCompletionFlash = false
    @State private var tapPulse = false

    @AppStorage("tasbeehTotalAllTime") private var totalAllTime: Int = 0
    @AppStorage("tasbeehLastDate") private var lastDateStr: String = ""
    @AppStorage("appLanguage") private var lang: String = "ar"

    private func s(_ ar: String, _ en: String) -> String { lang == "en" ? en : ar }

    var body: some View {
        ZStack {
            QiblatiTheme.backgroundGradient
                .ignoresSafeArea()

            IslamicPatternBackground(opacity: 0.05)
                .ignoresSafeArea()

            VStack(spacing: 14) {
                // Header
                headerSection

                // Dhikr selector
                dhikrSelector

                Spacer(minLength: 8)

                // Counter display
                counterDisplay

                Spacer(minLength: 8)

                // Tap button with progress ring
                tapButton

                Spacer(minLength: 8)

                // Stats
                statsSection
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 16)
        }
        .onAppear { loadDailyStats() }
    }

    private var headerSection: some View {
        VStack(spacing: 6) {
            Text(s("المسبحة", "Tasbeeh"))
                .font(QiblatiTheme.titleFont(size: 36))
                .foregroundStyle(QiblatiTheme.goldGradient)

            OrnamentalDivider(width: 180)
        }
    }

    private var dhikrSelector: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 10) {
                ForEach(Array(presets.enumerated()), id: \.offset) { index, preset in
                    let isSelected = selectedPreset == index
                    Button {
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.75)) {
                            selectedPreset = index
                            count = 0
                        }
                        #if os(iOS)
                        UISelectionFeedbackGenerator().selectionChanged()
                        #endif
                    } label: {
                        Text(preset.text)
                            .font(QiblatiTheme.arabicFont(size: 13))
                            .lineLimit(1)
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
            .padding(.horizontal, 4)
            .padding(.vertical, 4)
        }
    }

    private var counterDisplay: some View {
        VStack(spacing: 6) {
            // Dhikr text
            Text(presets[selectedPreset].text)
                .font(QiblatiTheme.arabicBoldFont(size: 26))
                .foregroundColor(QiblatiTheme.ivory)
                .multilineTextAlignment(.center)

            // Count
            let formatter = NumberFormatter()
            let _ = formatter.locale = Locale(identifier: "ar")
            let countStr = formatter.string(from: NSNumber(value: count)) ?? "\(count)"
            let targetStr = formatter.string(from: NSNumber(value: presets[selectedPreset].target)) ?? "\(presets[selectedPreset].target)"

            Text(countStr)
                .font(.system(size: 80, weight: .medium, design: .rounded))
                .foregroundStyle(showCompletionFlash ? AnyShapeStyle(QiblatiTheme.qiblaGreen) : AnyShapeStyle(QiblatiTheme.goldGradient))
                .contentTransition(.numericText())
                .animation(.easeInOut(duration: 0.15), value: count)

            // Target
            Text(lang == "en" ? "Target: \(targetStr)" : "الهدف: \(targetStr)")
                .font(QiblatiTheme.arabicFont(size: 14))
                .foregroundColor(QiblatiTheme.gold.opacity(0.6))
        }
    }

    private var tapButton: some View {
        Button {
            incrementCount()
        } label: {
            ZStack {
                // Track ring
                Circle()
                    .stroke(QiblatiTheme.gold.opacity(0.15), lineWidth: 6)
                    .frame(width: 176, height: 176)

                // Progress ring
                Circle()
                    .trim(from: 0, to: progress)
                    .stroke(
                        showCompletionFlash ? QiblatiTheme.qiblaGreen : QiblatiTheme.brightGold,
                        style: StrokeStyle(lineWidth: 6, lineCap: .round)
                    )
                    .frame(width: 176, height: 176)
                    .rotationEffect(.degrees(-90))
                    .shadow(color: (showCompletionFlash ? QiblatiTheme.qiblaGreen : QiblatiTheme.gold).opacity(0.5), radius: 6)
                    .animation(.easeOut(duration: 0.2), value: progress)

                // Bead at ring head
                if progress > 0.01 {
                    Circle()
                        .fill(QiblatiTheme.paleGold)
                        .frame(width: 12, height: 12)
                        .shadow(color: QiblatiTheme.gold.opacity(0.8), radius: 5)
                        .offset(y: -88)
                        .rotationEffect(.degrees(Double(progress) * 360))
                        .animation(.easeOut(duration: 0.2), value: progress)
                }

                // Button core
                Circle()
                    .fill(
                        RadialGradient(
                            colors: [
                                QiblatiTheme.surfaceLight.opacity(tapPulse ? 0.9 : 0.65),
                                QiblatiTheme.surfaceGreen.opacity(0.85),
                                QiblatiTheme.secondaryGreen,
                            ],
                            center: .center,
                            startRadius: 8,
                            endRadius: 80
                        )
                    )
                    .frame(width: 152, height: 152)
                    .overlay(
                        Circle()
                            .strokeBorder(
                                showCompletionFlash ? QiblatiTheme.qiblaGreen.opacity(0.7) : QiblatiTheme.gold.opacity(0.45),
                                lineWidth: 1.5
                            )
                    )
                    .shadow(color: .black.opacity(0.5), radius: 14, y: 6)
                    .shadow(color: QiblatiTheme.gold.opacity(tapPulse ? 0.4 : 0.15), radius: tapPulse ? 18 : 8)
                    .scaleEffect(tapPulse ? 0.94 : 1.0)

                VStack(spacing: 5) {
                    Image(systemName: "hand.tap.fill")
                        .font(.system(size: 34))
                        .foregroundStyle(QiblatiTheme.goldGradient)
                    Text(s("اضغط", "Tap"))
                        .font(QiblatiTheme.arabicFont(size: 16))
                        .foregroundColor(QiblatiTheme.gold.opacity(0.85))
                }
            }
        }
        .buttonStyle(.plain)
        .simultaneousGesture(
            DragGesture(minimumDistance: 0)
                .onChanged { _ in
                    if !tapPulse {
                        withAnimation(.easeOut(duration: 0.1)) { tapPulse = true }
                    }
                }
                .onEnded { _ in
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.5)) { tapPulse = false }
                }
        )
        // Reset button
        .overlay(alignment: .trailing) {
            if count > 0 {
                Button {
                    withAnimation { count = 0 }
                    #if os(iOS)
                    UIImpactFeedbackGenerator(style: .rigid).impactOccurred()
                    #endif
                } label: {
                    Image(systemName: "arrow.counterclockwise.circle.fill")
                        .font(.system(size: 30))
                        .foregroundColor(QiblatiTheme.gold.opacity(0.5))
                        .shadow(color: .black.opacity(0.4), radius: 4)
                }
                .buttonStyle(.plain)
                .offset(x: 64)
            }
        }
    }

    private var statsSection: some View {
        HStack(spacing: 0) {
            statItem(label: s("اليوم", "Today"), value: totalToday + count)
            Rectangle()
                .fill(QiblatiTheme.gold.opacity(0.2))
                .frame(width: 0.8, height: 34)
            statItem(label: s("الإجمالي", "Total"), value: totalAllTime + count)
        }
        .padding(.vertical, 12)
        .qiblatiCard(cornerRadius: 16)
        .padding(.bottom, 100)
    }

    private func statItem(label: String, value: Int) -> some View {
        VStack(spacing: 3) {
            let formatter = NumberFormatter()
            let _ = formatter.locale = Locale(identifier: "ar")
            let str = formatter.string(from: NSNumber(value: value)) ?? "\(value)"
            Text(str)
                .font(QiblatiTheme.arabicBoldFont(size: 22))
                .foregroundStyle(QiblatiTheme.goldGradient)
                .contentTransition(.numericText())
            Text(label)
                .font(QiblatiTheme.arabicFont(size: 13))
                .foregroundColor(QiblatiTheme.gold.opacity(0.65))
        }
        .frame(maxWidth: .infinity)
    }

    // MARK: - Logic

    private var progress: CGFloat {
        let target = presets[selectedPreset].target
        guard target > 0 else { return 0 }
        return min(CGFloat(count) / CGFloat(target), 1.0)
    }

    private func incrementCount() {
        count += 1
        #if os(iOS)
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
        #endif

        if count >= presets[selectedPreset].target {
            showCompletionFlash = true
            #if os(iOS)
            UINotificationFeedbackGenerator().notificationOccurred(.success)
            #endif
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
                showCompletionFlash = false
            }
            // Save completed set
            totalToday += count
            totalAllTime += count
            saveDailyStats()
            count = 0
        }
    }

    private func loadDailyStats() {
        let today = formattedToday()
        if lastDateStr != today {
            totalToday = 0
            lastDateStr = today
        }
    }

    private func saveDailyStats() {
        lastDateStr = formattedToday()
    }

    private func formattedToday() -> String {
        let f = DateFormatter()
        f.dateFormat = "yyyy-MM-dd"
        return f.string(from: Date())
    }
}
