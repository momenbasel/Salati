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

    @AppStorage("tasbeehTotalAllTime") private var totalAllTime: Int = 0
    @AppStorage("tasbeehLastDate") private var lastDateStr: String = ""
    @AppStorage("appLanguage") private var lang: String = "ar"

    private func s(_ ar: String, _ en: String) -> String { lang == "en" ? en : ar }

    var body: some View {
        ZStack {
            RadialGradient(
                colors: [QiblatiTheme.primaryGreen, QiblatiTheme.secondaryGreen],
                center: .center, startRadius: 0, endRadius: 440
            )
            .ignoresSafeArea()

            IslamicPatternBackground(opacity: 0.05)
                .ignoresSafeArea()

            VStack(spacing: 16) {
                // Header
                headerSection

                // Dhikr selector
                dhikrSelector

                Spacer()

                // Counter display
                counterDisplay

                Spacer()

                // Tap button
                tapButton

                Spacer()

                // Stats
                statsSection
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 16)
        }
        .onAppear { loadDailyStats() }
    }

    private var headerSection: some View {
        VStack(spacing: 4) {
            Text(s("المسبحة", "Tasbeeh"))
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

    private var dhikrSelector: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 10) {
                ForEach(Array(presets.enumerated()), id: \.offset) { index, preset in
                    let isSelected = selectedPreset == index
                    Button {
                        withAnimation(.easeInOut(duration: 0.2)) {
                            selectedPreset = index
                            count = 0
                        }
                    } label: {
                        Text(preset.text)
                            .font(QiblatiTheme.arabicFont(size: 13))
                            .lineLimit(1)
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
            .padding(.horizontal, 4)
        }
    }

    private var counterDisplay: some View {
        VStack(spacing: 8) {
            // Dhikr text
            Text(presets[selectedPreset].text)
                .font(QiblatiTheme.arabicBoldFont(size: 26))
                .foregroundColor(.white)
                .multilineTextAlignment(.center)

            // Count
            let formatter = NumberFormatter()
            let _ = formatter.locale = Locale(identifier: "ar")
            let countStr = formatter.string(from: NSNumber(value: count)) ?? "\(count)"
            let targetStr = formatter.string(from: NSNumber(value: presets[selectedPreset].target)) ?? "\(presets[selectedPreset].target)"

            Text(countStr)
                .font(.system(size: 86, weight: .medium, design: .rounded))
                .foregroundStyle(showCompletionFlash ? AnyShapeStyle(Color.green) : AnyShapeStyle(QiblatiTheme.goldGradient))
                .contentTransition(.numericText())
                .animation(.easeInOut(duration: 0.15), value: count)

            // Progress
            Text(lang == "en" ? "Target: \(targetStr)" : "الهدف: \(targetStr)")
                .font(QiblatiTheme.arabicFont(size: 14))
                .foregroundColor(QiblatiTheme.gold.opacity(0.6))

            // Progress bar
            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    Capsule()
                        .fill(QiblatiTheme.secondaryGreen)
                        .frame(height: 6)

                    Capsule()
                        .fill(QiblatiTheme.goldGradient)
                        .frame(width: geo.size.width * progress, height: 6)
                        .animation(.easeOut(duration: 0.2), value: progress)
                }
            }
            .frame(height: 6)
            .padding(.horizontal, 40)
        }
    }

    private var tapButton: some View {
        Button {
            incrementCount()
        } label: {
            ZStack {
                Circle()
                    .fill(QiblatiTheme.secondaryGreen.opacity(0.6))
                    .frame(width: 140, height: 140)
                    .overlay(
                        Circle()
                            .strokeBorder(
                                showCompletionFlash ? Color.green.opacity(0.6) : QiblatiTheme.gold.opacity(0.4),
                                lineWidth: 2
                            )
                    )
                    .shadow(color: QiblatiTheme.gold.opacity(0.2), radius: 10)

                VStack(spacing: 4) {
                    Image(systemName: "hand.tap.fill")
                        .font(.system(size: 32))
                        .foregroundColor(QiblatiTheme.gold)
                    Text(s("اضغط", "Tap"))
                        .font(QiblatiTheme.arabicFont(size: 16))
                        .foregroundColor(QiblatiTheme.gold.opacity(0.8))
                }
            }
        }
        .buttonStyle(.plain)

        // Reset button
        .overlay(alignment: .trailing) {
            if count > 0 {
                Button {
                    withAnimation { count = 0 }
                } label: {
                    Image(systemName: "arrow.counterclockwise.circle.fill")
                        .font(.system(size: 28))
                        .foregroundColor(QiblatiTheme.gold.opacity(0.5))
                }
                .buttonStyle(.plain)
                .offset(x: 80)
            }
        }
    }

    private var statsSection: some View {
        HStack(spacing: 0) {
            statItem(label: s("اليوم", "Today"), value: totalToday + count)
            Divider()
                .background(QiblatiTheme.gold.opacity(0.3))
                .frame(height: 30)
            statItem(label: s("الإجمالي", "Total"), value: totalAllTime + count)
        }
        .padding(.vertical, 12)
        .background(
            RoundedRectangle(cornerRadius: 14)
                .fill(QiblatiTheme.secondaryGreen.opacity(0.4))
                .overlay(
                    RoundedRectangle(cornerRadius: 14)
                        .strokeBorder(QiblatiTheme.gold.opacity(0.15), lineWidth: 1)
                )
        )
        .padding(.bottom, 80)
    }

    private func statItem(label: String, value: Int) -> some View {
        VStack(spacing: 4) {
            let formatter = NumberFormatter()
            let _ = formatter.locale = Locale(identifier: "ar")
            let str = formatter.string(from: NSNumber(value: value)) ?? "\(value)"
            Text(str)
                .font(QiblatiTheme.arabicBoldFont(size: 24))
                .foregroundStyle(QiblatiTheme.goldGradient)
            Text(label)
                .font(QiblatiTheme.arabicFont(size: 14))
                .foregroundColor(QiblatiTheme.gold.opacity(0.7))
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
