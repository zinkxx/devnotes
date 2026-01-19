import SwiftUI

// MARK: - APP THEME

enum AppTheme: String, CaseIterable, Identifiable {
    case system = "Sistem"
    case light = "Açık"
    case dark = "Koyu"

    var id: String { rawValue }

    var icon: String {
        switch self {
        case .system: return "gearshape"
        case .light: return "sun.max.fill"
        case .dark: return "moon.fill"
        }
    }

    var colorScheme: ColorScheme? {
        switch self {
        case .system: return nil
        case .light: return .light
        case .dark: return .dark
        }
    }
}

// MARK: - SETTINGS VIEW

struct SettingsView: View {

    // MARK: - STORED SETTINGS
    @AppStorage("appTheme") private var selectedThemeRaw = AppTheme.system.rawValue
    @AppStorage("icloudSyncEnabled") private var iCloudSyncEnabled = true
    @AppStorage("hapticEnabled") private var hapticEnabled = true

    // MARK: - UI STATE
    @State private var showAbout = false
    @State private var showDeleteAlert = false

    // MARK: - DERIVED
    private var selectedTheme: AppTheme {
        AppTheme(rawValue: selectedThemeRaw) ?? .system
    }

    var body: some View {
        NavigationStack {
            List {

                // MARK: - GENERAL
                Section("Genel") {

                    NavigationLink {
                        ThemePickerView(
                            selectedTheme: selectedTheme,
                            onSelect: { theme in
                                selectedThemeRaw = theme.rawValue
                            }
                        )
                    } label: {
                        settingsRow(
                            title: "Tema",
                            subtitle: selectedTheme.rawValue,
                            icon: selectedTheme.icon
                        )
                    }

                    Toggle(isOn: $iCloudSyncEnabled) {
                        settingsRow(
                            title: "iCloud Senkronizasyon",
                            subtitle: "Notlarını cihazlar arasında eşitle",
                            icon: "icloud.fill"
                        )
                    }

                    Toggle(isOn: $hapticEnabled) {
                        settingsRow(
                            title: "Titreşim (Haptic)",
                            subtitle: "Dokunma geri bildirimi",
                            icon: "waveform.path"
                        )
                    }
                }

                // MARK: - ABOUT
                Section("Hakkında") {

                    Button {
                        showAbout = true
                    } label: {
                        settingsRow(
                            title: "Uygulama Hakkında",
                            subtitle: "DevNotes bilgileri",
                            icon: "info.circle.fill"
                        )
                    }

                    HStack {
                        Text("Sürüm")
                        Spacer()
                        Text(appVersion)
                            .foregroundStyle(.secondary)
                    }
                }

                // MARK: - DANGER ZONE
                Section("Tehlikeli Bölge") {

                    Button(role: .destructive) {
                        showDeleteAlert = true
                    } label: {
                        settingsRow(
                            title: "Tüm Notları Sil",
                            subtitle: "Bu işlem geri alınamaz",
                            icon: "trash.fill",
                            tint: .red
                        )
                    }
                }
            }
            .navigationTitle("Ayarlar")
            .sheet(isPresented: $showAbout) {
                AboutDevNotesView()
            }
            .alert("Emin misin?", isPresented: $showDeleteAlert) {
                Button("Sil", role: .destructive) {
                    NoteRepository.shared.deleteAll()
                }
                Button("Vazgeç", role: .cancel) {}
            } message: {
                Text("Tüm notlar kalıcı olarak silinecek.")
            }
        }
        // 🔥 Tema anında uygulanır
        .preferredColorScheme(selectedTheme.colorScheme)
    }

    // MARK: - SETTINGS ROW

    private func settingsRow(
        title: String,
        subtitle: String,
        icon: String,
        tint: Color = .accentColor
    ) -> some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .foregroundStyle(tint)
                .frame(width: 26)

            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.body)
                Text(subtitle)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
        .padding(.vertical, 4)
    }

    // MARK: - APP VERSION

    private var appVersion: String {
        let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "-"
        let build = Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "-"
        return "v\(version) (\(build))"
    }
}
