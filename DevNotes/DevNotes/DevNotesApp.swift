import SwiftUI
import CoreData

@main
struct DevNotesApp: App {

    let persistenceController = PersistenceController.shared

    // 🔥 Tema ayarını buradan okuyoruz
    @AppStorage("appTheme") private var selectedThemeRaw = AppTheme.system.rawValue

    private var selectedTheme: ColorScheme? {
        switch AppTheme(rawValue: selectedThemeRaw) {
        case .light:
            return .light
        case .dark:
            return .dark
        default:
            return nil // System
        }
    }

    var body: some Scene {
        WindowGroup {
            MainTabView()
                // ✅ CoreData aynen duruyor
                .environment(
                    \.managedObjectContext,
                    persistenceController.container.viewContext
                )
                // ✅ Tema eklendi (tek satır)
                .preferredColorScheme(selectedTheme)
        }
    }
}
