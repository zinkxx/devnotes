import SwiftUI

struct MainTabView: View {

    @State private var selectedTab = 0

    var body: some View {
        TabView(selection: $selectedTab) {

            // 📝 NOTLAR
            NavigationStack {
                ContentView()
            }
            .tabItem {
                Label("Notlar", systemImage: "note.text")
            }
            .tag(0)

            // 📌 SABİTLENENLER
            NavigationStack {
                PinnedNotesView()
            }
            .tabItem {
                Label("Sabit", systemImage: "pin")
            }
            .tag(1)

            // ⏰ HATIRLATMALAR
            NavigationStack {
                RemindersView()
            }
            .tabItem {
                Label("Hatırlat", systemImage: "bell.badge")
            }
            .tag(2)

            // ⚙️ AYARLAR
            NavigationStack {
                SettingsView()
            }
            .tabItem {
                Label("Ayarlar", systemImage: "gearshape")
            }
            .tag(3)
        }
        .tint(.accentColor)
    }
}
