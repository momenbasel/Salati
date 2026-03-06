import SwiftUI
import CoreLocation

struct ContentView: View {
    @StateObject private var locationManager = LocationManager()
    @AppStorage("hasSeenDedication") private var hasSeenDedication = false
    @AppStorage("appLanguage") private var lang: String = "ar"
    @State private var showDedication = false
    @State private var selectedTab: Tab = .compass

    enum Tab: String {
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

            customTabBar
        }
    }

    private var customTabBar: some View {
        HStack(spacing: 0) {
            tabItem(tab: .compass, icon: "location.north.fill", label: lang == "en" ? "Qibla" : "القبلة")
            tabItem(tab: .prayers, icon: "clock.fill", label: lang == "en" ? "Prayers" : "المواقيت")
            tabItem(tab: .adhkar, icon: "text.book.closed.fill", label: lang == "en" ? "Adhkar" : "الأذكار")
            tabItem(tab: .tasbeeh, icon: "circle.dotted", label: lang == "en" ? "Tasbeeh" : "المسبحة")
            tabItem(tab: .settings, icon: "gearshape.fill", label: lang == "en" ? "Settings" : "الإعدادات")
        }
        .padding(.horizontal, 8)
        .padding(.top, 10)
        .padding(.bottom, 6)
        .background(
            Rectangle()
                .fill(.ultraThinMaterial)
                .environment(\.colorScheme, .dark)
                .overlay(
                    Rectangle()
                        .fill(QiblatiTheme.secondaryGreen.opacity(0.7))
                )
                .overlay(alignment: .top) {
                    Rectangle()
                        .fill(QiblatiTheme.gold.opacity(0.2))
                        .frame(height: 0.5)
                }
        )
        .ignoresSafeArea(.container, edges: .bottom)
    }

    private func tabItem(tab: Tab, icon: String, label: String) -> some View {
        let isSelected = selectedTab == tab
        return Button {
            withAnimation(.easeInOut(duration: 0.15)) {
                selectedTab = tab
            }
        } label: {
            VStack(spacing: 4) {
                Image(systemName: icon)
                    .font(.system(size: 20))
                    .foregroundColor(isSelected ? QiblatiTheme.brightGold : QiblatiTheme.gold.opacity(0.4))
                Text(label)
                    .font(QiblatiTheme.arabicFont(size: 10))
                    .foregroundColor(isSelected ? QiblatiTheme.brightGold : QiblatiTheme.gold.opacity(0.4))
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 4)
        }
        .buttonStyle(.plain)
    }

}

#Preview {
    ContentView()
}
