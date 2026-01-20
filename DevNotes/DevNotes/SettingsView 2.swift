import SwiftUI
import UserNotifications
import UIKit

private enum NotificationHelper {
    static func checkAuthorizationStatus(completion: @escaping (UNAuthorizationStatus) -> Void) {
        UNUserNotificationCenter.current().getNotificationSettings { settings in
            completion(settings.authorizationStatus)
        }
    }

    static func requestAuthorization(completion: ((Bool) -> Void)? = nil) {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { granted, _ in
            completion?(granted)
        }
    }

    static func openSettings() {
        guard let url = URL(string: UIApplication.openSettingsURLString) else { return }
        if UIApplication.shared.canOpenURL(url) {
            UIApplication.shared.open(url)
        }
    }
}

struct AppSettingsView: View {
    @State private var authorizationStatus: UNAuthorizationStatus = .notDetermined

    var body: some View {
        List {
            Section("Bildirimler") {
                HStack {
                    Text("İzin Durumu")
                    Spacer()
                    Text(statusText)
                        .foregroundStyle(statusColor)
                        .font(.subheadline)
                }

                Button("Bildirim izni iste") {
                    NotificationHelper.requestAuthorization { _ in
                        refreshStatus()
                    }
                }

                Button("Sistem Bildirim Ayarlarını Aç") {
                    NotificationHelper.openSettings()
                }
            }
        }
        .navigationTitle("Ayarlar")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear { refreshStatus() }
    }

    private var statusText: String {
        switch authorizationStatus {
        case .authorized, .provisional: return "İzinli"
        case .denied: return "İzinli değil"
        case .notDetermined: return "Belirsiz"
        @unknown default: return "Bilinmiyor"
        }
    }

    private var statusColor: Color {
        switch authorizationStatus {
        case .authorized, .provisional: return .green
        case .denied: return .red
        default: return .secondary
        }
    }

    private func refreshStatus() {
        NotificationHelper.checkAuthorizationStatus { status in
            DispatchQueue.main.async {
                self.authorizationStatus = status
            }
        }
    }
}

#Preview {
    NavigationStack { AppSettingsView() }
}
