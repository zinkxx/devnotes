// MARK: - NOTIFICATION MANAGER
private struct NotificationManager {

    static func requestAuthorization(completion: ((Bool) -> Void)? = nil) {
        UNUserNotificationCenter.current()
            .requestAuthorization(options: [.alert, .badge, .sound]) { granted, _ in
                DispatchQueue.main.async {
                    completion?(granted)
                }
            }
    }

    static func checkAuthorizationStatus(completion: @escaping (Bool) -> Void) {
        UNUserNotificationCenter.current()
            .getNotificationSettings { settings in
                DispatchQueue.main.async {
                    completion(
                        settings.authorizationStatus == .authorized ||
                        settings.authorizationStatus == .provisional
                    )
                }
            }
    }

    static func openSettings() {
        guard let url = URL(string: UIApplication.openSettingsURLString) else { return }
        if UIApplication.shared.canOpenURL(url) {
            UIApplication.shared.open(url)
        }
    }

    static func scheduleNotification(for note: Note) {
        guard let date = note.reminderDate else { return }
        if date < Date() { return }

        let content = UNMutableNotificationContent()
        content.title = note.title
        content.body = note.content
        content.sound = .default

        let triggerDate = Calendar.current.dateComponents(
            [.year, .month, .day, .hour, .minute],
            from: date
        )

        let trigger = UNCalendarNotificationTrigger(
            dateMatching: triggerDate,
            repeats: false
        )

        let request = UNNotificationRequest(
            identifier: note.id.uuidString,
            content: content,
            trigger: trigger
        )

        UNUserNotificationCenter.current().add(request)
    }

    static func cancelNotification(for note: Note) {
        UNUserNotificationCenter.current()
            .removePendingNotificationRequests(
                withIdentifiers: [note.id.uuidString]
            )
    }
}
