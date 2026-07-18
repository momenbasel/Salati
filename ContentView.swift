import SwiftUI
import CoreLocation

struct ContentView: View {
    @StateObject private var locationManager = LocationManager()
    @AppStorage("hasSeenDedication") private var hasSeenDedication = false
    @AppStorage("appLanguage") private var lang: String = "ar"
    @State private var showDedication = false
    @State private var selectedTab: Tab = .compass

    @Namespace private var tabNamespace

    enum Tab: String, CaseIterable {
        case compass, prayers, adhkar, tasbeeh, settings
    }

    var body: some View {
        mainTabView
            .overlay {
                if showDedication {
                    DedicationPopup(isPresented: $showDedication)
                        .onDisappear { hasSeenDedication = true }
                }
            }
            .onAppear {
                locationManager.requestPermission()
                showDedication = !hasSeenDedication
            }
    }

    private var locationDenied: Bool {
        let status = locationManager.authorizationStatus
        return status == .denied || status == .restricted
    }

    private var mainTabView: some View {
        ZStack(alignment: .bottom) {
            Group {
                switch selectedTab {
                case .compass:
                    if locationDenied {
                        LocationDeniedView()
                    } else {
                        CompassView(locationManager: locationManager)
                    }
                case .prayers:
                    if locationDenied {
                        LocationDeniedView()
                    } else {
                        PrayerTimesView(locationManager: locationManager)
                    }
                case .adhkar:
                    AdhkarView()
                case .tasbeeh:
                    TasbeehView()
                case .settings:
                    SettingsView()
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)

            customTabBar
        }
    }

    // MARK: - Floating Tab Bar

    private var customTabBar: some View {
        HStack(spacing: 0) {
            tabItem(tab: .compass, icon: "location.north.fill", label: lang == "en" ? "Qibla" : "القبلة")
            tabItem(tab: .prayers, icon: "clock.fill", label: lang == "en" ? "Prayers" : "المواقيت")
            tabItem(tab: .adhkar, icon: "text.book.closed.fill", label: lang == "en" ? "Adhkar" : "الأذكار")
            tabItem(tab: .tasbeeh, icon: "circle.dotted", label: lang == "en" ? "Tasbeeh" : "المسبحة")
            tabItem(tab: .settings, icon: "gearshape.fill", label: lang == "en" ? "Settings" : "الإعدادات")
        }
        .padding(.horizontal, 6)
        .padding(.vertical, 8)
        .background(
            Capsule(style: .continuous)
                .fill(QiblatiTheme.abyssGreen.opacity(0.92))
                .overlay(
                    Capsule(style: .continuous)
                        .strokeBorder(QiblatiTheme.gold.opacity(0.3), lineWidth: 0.8)
                )
                .shadow(color: .black.opacity(0.5), radius: 18, x: 0, y: 8)
                .shadow(color: QiblatiTheme.gold.opacity(0.12), radius: 12, x: 0, y: 2)
        )
        .padding(.horizontal, 16)
        .padding(.bottom, 10)
    }

    private func tabItem(tab: Tab, icon: String, label: String) -> some View {
        let isSelected = selectedTab == tab
        return Button {
            withAnimation(.spring(response: 0.35, dampingFraction: 0.72)) {
                selectedTab = tab
            }
        } label: {
            VStack(spacing: 3) {
                Image(systemName: icon)
                    .font(.system(size: 17, weight: .semibold))
                Text(label)
                    .font(QiblatiTheme.arabicFont(size: 10))
            }
            .foregroundColor(isSelected ? QiblatiTheme.abyssGreen : QiblatiTheme.gold.opacity(0.55))
            .frame(maxWidth: .infinity)
            .padding(.vertical, 8)
            .background {
                if isSelected {
                    Capsule(style: .continuous)
                        .fill(QiblatiTheme.goldGradient)
                        .shadow(color: QiblatiTheme.gold.opacity(0.45), radius: 8, x: 0, y: 2)
                        .matchedGeometryEffect(id: "tabPill", in: tabNamespace)
                }
            }
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }

}

#Preview {
    ContentView()
}
