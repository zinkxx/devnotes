import SwiftUI
import UserNotifications
import UIKit

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

// MARK: - NOTIFICATION HELPER

private enum SettingsNotificationHelper {
    static func checkStatus(completion: @escaping (UNAuthorizationStatus) -> Void) {
        UNUserNotificationCenter.current().getNotificationSettings { settings in
            completion(settings.authorizationStatus)
        }
    }

    static func request(completion: ((Bool) -> Void)? = nil) {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { granted, _ in
            completion?(granted)
        }
    }

    static func openSystemSettings() {
        guard let url = URL(string: UIApplication.openSettingsURLString) else { return }
        if UIApplication.shared.canOpenURL(url) {
            UIApplication.shared.open(url)
        }
    }
}

// MARK: - SETTINGS VIEW

struct SettingsView: View {

    // MARK: - STORED SETTINGS
    @AppStorage("appTheme") private var selectedThemeRaw = AppTheme.system.rawValue
    @AppStorage("icloudSyncEnabled") private var iCloudSyncEnabled = true
    @AppStorage("hapticEnabled") private var hapticEnabled = true
    // App-level switch to control scheduling of notifications inside the app
    @AppStorage("notificationsEnabled") private var notificationsEnabled = true

    // MARK: - UI STATE
    @State private var showAbout = false
    @State private var showDeleteAlert = false
    @State private var notificationStatus: UNAuthorizationStatus = .notDetermined
    @State private var showingSystemSettingsTip = false

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

                    Toggle(isOn: Binding(
                        get: { notificationsEnabled },
                        set: { newValue in
                            handleNotificationsToggleChange(newValue)
                        }
                    )) {
                        settingsRow(
                            title: "Bildirimler",
                            subtitle: notificationSubtitle,
                            icon: "bell.badge.fill"
                        )
                    }

                    if showingSystemSettingsTip {
                        Button("Sistem Bildirim Ayarlarını Aç") {
                            SettingsNotificationHelper.openSystemSettings()
                        }
                        .font(.footnote)
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
                // MARK: - SUPPORT & LEGAL
                Section("Destek & Yasal") {

                    Button {
                        openAppStoreReview()
                    } label: {
                        settingsRow(
                            title: "Uygulamayı Değerlendir",
                            subtitle: "App Store’da oy ver",
                            icon: "star.fill",
                            tint: .yellow
                        )
                    }

                    Button {
                        sendFeedbackMail()
                    } label: {
                        settingsRow(
                            title: "Geri Bildirim Gönder",
                            subtitle: "Öneri & hata bildir",
                            icon: "envelope.fill",
                            tint: .blue
                        )
                    }

                    NavigationLink {
                        PrivacyPolicyView()
                    } label: {
                        settingsRow(
                            title: "Gizlilik Politikası",
                            subtitle: "Veriler nasıl kullanılır",
                            icon: "lock.shield.fill"
                        )
                    }

                    NavigationLink {
                        TermsOfServiceView()
                    } label: {
                        settingsRow(
                            title: "Kullanım Şartları",
                            subtitle: "Yasal kullanım koşulları",
                            icon: "doc.text.fill"
                        )
                    }

                    NavigationLink {
                        LicensesView()
                    } label: {
                        settingsRow(
                            title: "Açık Kaynak Lisansları",
                            subtitle: "Kullanılan kütüphaneler",
                            icon: "curlybraces"
                        )
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
            .onAppear {
                refreshNotificationStatus()
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

    // MARK: - NOTIFICATION HELPERS

    private var notificationSubtitle: String {
        switch notificationStatus {
        case .authorized, .provisional: return notificationsEnabled ? "Açık" : "Kapalı"
        case .denied: return "Sistem izni kapalı"
        case .notDetermined: return "İzin sorulacak"
        @unknown default: return "Bilinmiyor"
        }
    }

    private func handleNotificationsToggleChange(_ newValue: Bool) {
        if newValue {
            // User turning ON: request if needed
            SettingsNotificationHelper.checkStatus { status in
                switch status {
                case .authorized, .provisional:
                    DispatchQueue.main.async {
                        self.notificationsEnabled = true
                        self.showingSystemSettingsTip = false
                        self.notificationStatus = status
                    }
                case .denied:
                    // Cannot enable without system permission
                    DispatchQueue.main.async {
                        self.notificationsEnabled = false
                        self.showingSystemSettingsTip = true
                        self.notificationStatus = status
                    }
                case .notDetermined:
                    SettingsNotificationHelper.request { granted in
                        DispatchQueue.main.async {
                            self.notificationsEnabled = granted
                            self.showingSystemSettingsTip = !granted
                            refreshNotificationStatus()
                        }
                    }
                @unknown default:
                    DispatchQueue.main.async {
                        self.notificationsEnabled = false
                        self.showingSystemSettingsTip = true
                    }
                }
            }
        } else {
            // User turning OFF: app-level disable only
            notificationsEnabled = false
            // Keep status as-is; optionally suggest system settings if status is denied
            showingSystemSettingsTip = (notificationStatus == .denied)
        }
    }

    private func refreshNotificationStatus() {
        SettingsNotificationHelper.checkStatus { status in
            DispatchQueue.main.async {
                self.notificationStatus = status
                // If system is denied, show tip and force app-level off
                if status == .denied { self.notificationsEnabled = false; self.showingSystemSettingsTip = true }
            }
        }
    }

    // MARK: - APP VERSION

    private var appVersion: String {
        let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "-"
        let build = Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "-"
        return "v\(version) (\(build))"
    }
    private func sendFeedbackMail() {
         let email = "support@devnotes.app"
         let subject = "DevNotes Geri Bildirim"
         let body = "Uygulama Sürümü: \(appVersion)\n\nGeri bildiriminiz:"

         let mailString =
             "mailto:\(email)?subject=\(subject)&body=\(body)"
                 .addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)

         if let url = URL(string: mailString ?? "") {
             UIApplication.shared.open(url)
         }
     }
}

// MARK: - SUPPORT HELPERS

private func openAppStoreReview() {
    if let url = URL(string: "itms-apps://itunes.apple.com/app/idYOUR_APP_ID?action=write-review") {
        UIApplication.shared.open(url)
    }
}
