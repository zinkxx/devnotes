import SwiftUI
import UserNotifications
import UIKit

struct RemindersView: View {

    // MARK: - NOTIFICATION MANAGER
    private struct NotificationManager {

        static func requestAuthorization(completion: @escaping (Bool) -> Void) {
            UNUserNotificationCenter.current()
                .requestAuthorization(options: [.alert, .badge, .sound]) { granted, _ in
                    DispatchQueue.main.async {
                        completion(granted)
                    }
                }
        }

        static func openAppSettings() {
            guard let url = URL(string: UIApplication.openSettingsURLString),
                  UIApplication.shared.canOpenURL(url)
            else { return }

            UIApplication.shared.open(url)
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

    // MARK: - STATE
    @State private var notes: [Note] = []
    @State private var searchText = ""

    @AppStorage("hasRequestedNotificationPermission")
    private var hasRequestedNotificationPermission = false


    @AppStorage("notificationPermissionGranted")
    private var notificationPermissionGranted = false

    @AppStorage("notificationsEnabled")
    private var notificationsEnabled = true

    @Environment(\.colorScheme) private var colorScheme
    @Environment(\.scenePhase) private var scenePhase


    // MARK: - FILTER
    private enum ReminderFilter: String, CaseIterable, Identifiable {
        case all = "Hepsi"
        case overdue = "Gecikmiş"
        case upcoming = "Yaklaşan"

        var id: String { rawValue }
    }

    @State private var selectedFilter: ReminderFilter = .all

    // MARK: - DATE FILTER
    private enum DateFilter: String, CaseIterable, Identifiable {
        case all = "Tümü"
        case today = "Bugün"
        case week = "Bu Hafta"
        case month = "Bu Ay"
        case custom = "Tarih"

        var id: String { rawValue }
    }

    @State private var selectedDateFilter: DateFilter = .all
    @State private var customDate = Date()
    @State private var showDatePicker = false

    // MARK: - BODY
    var body: some View {
        NavigationStack {
            ZStack {
                Color("AppBackground")
                    .ignoresSafeArea()

                VStack(spacing: 12) {

                    // 🔔 Permission warning
                    if !notificationPermissionGranted || !notificationsEnabled {
                        notificationWarning
                            .padding(.horizontal)
                            .transition(.move(edge: .top).combined(with: .opacity))
                            .animation(.easeInOut, value: notificationPermissionGranted)
                    }
                    content
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .searchable(text: $searchText, prompt: "Hatırlatmalarda ara")
            .toolbar {
                ToolbarItem(placement: .principal) {
                    HStack(spacing: 8) {
                        Image(systemName: "alarm.fill")
                            .foregroundStyle(.red)

                        Text("Hatırlatmalar")
                            .font(.headline)
                            .foregroundStyle(Color("PrimaryText"))
                    }
                }
                // ✅ BURAYA EKLENDİ
                ToolbarItem(placement: .bottomBar) {
                    Picker("Filtre", selection: $selectedFilter) {
                        ForEach(ReminderFilter.allCases) {
                            Text($0.rawValue).tag($0)
                        }
                    }
                    .pickerStyle(.segmented)
                    .frame(maxWidth: 420)
                    .padding(.horizontal)
                    .toolbarBackground(.ultraThinMaterial, for: .bottomBar)
                }

                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        loadNotes()
                    } label: {
                        Image(systemName: "arrow.clockwise")
                    }
                }
            }
        }
        // 🔴 BURASI ÇOK ÖNEMLİ
        .onAppear {
            refreshSystemNotificationPermission()
            loadNotes()
        }
        .onChange(of: scenePhase) {
            if scenePhase == .active {
                refreshSystemNotificationPermission()
            }
        }
    }


    // MARK: - NOTIFICATION WARNING
    private var notificationWarning: some View {
        HStack(spacing: 12) {
            Image(systemName: "bell.slash.fill")
                .font(.title3)
                .foregroundStyle(.yellow)

            VStack(alignment: .leading, spacing: 4) {
                Text("Bildirimler Kapalı")
                    .font(.headline)
                    .foregroundStyle(Color("PrimaryText"))

                Text("Hatırlatmaların çalışması için bildirimlere izin vermen gerekiyor.")
                    .font(.caption)
                    .foregroundStyle(Color("SecondaryText"))

                Text("Butona dokunduktan sonra aşağıdaki yolu izleyebilirsin.")
                    .font(.caption2)
                    .foregroundStyle(Color("SecondaryText"))

                HStack(spacing: 4) {
                    Image(systemName: "arrow.turn.down.right")
                    Text("Ayarlar > DevNotes > Bildirimler")
                }
                .font(.caption2)
                .foregroundStyle(.secondary)
            }



            Spacer()
            Button(bannerButtonTitle) {
                handleBannerAction()
            }
            .font(.caption.bold())
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.yellow.opacity(colorScheme == .dark ? 0.18 : 0.12))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(Color.yellow.opacity(0.35), lineWidth: 1)
        )
    }

    // MARK: - CONTENT
    @ViewBuilder
    private var content: some View {
        if filteredReminderNotes.isEmpty {
            emptyState
        } else {
            ScrollView {
                LazyVStack(spacing: 14) {

                    if selectedFilter == .all {
                        // 🔹 SADECE "Hepsi" için section'lı görünüm
                        ForEach(
                            sectionedNotes.keys.sorted(by: { $0.order < $1.order }),
                            id: \.self
                        ) { key in
                            let notesInSection = sectionedNotes[key] ?? []
                            if !notesInSection.isEmpty {
                                sectionView(title: key.title, notes: notesInSection)
                            }
                        }
                    } else {
                        // 🔹 Gecikmiş / Yaklaşan → düz + SIRALI liste
                        ForEach(
                            filteredReminderNotes.sorted {
                                ($0.reminderDate ?? Date()) < ($1.reminderDate ?? Date())
                            }
                        ) { note in
                            NavigationLink {
                                EditNoteView(
                                    note: note,
                                    onSave: { _ in
                                        loadNotes()
                                    },
                                    onDelete: { deletedNote in
                                        NoteRepository.shared.delete(deletedNote)
                                        loadNotes()
                                    }
                                )
                            } label: {
                                reminderCard(note)
                            }
                            .buttonStyle(.plain)
                        }
                    }
                }
                .padding(.horizontal)
                .padding(.top, 8)
            }
        }
    }

    private func sectionView(title: String, notes: [Note]) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.footnote.weight(.semibold))
                .foregroundStyle(.secondary)
                .padding(.leading, 4)

            ForEach(notes) { note in
                NavigationLink {
                    EditNoteView(
                        note: note,
                        onSave: { _ in
                            loadNotes()
                        },
                        onDelete: { deletedNote in
                            NoteRepository.shared.delete(deletedNote)
                            loadNotes()
                        }
                    )
                } label: {
                    reminderCard(note)
                }
                .buttonStyle(.plain)
            }
        }
    }


    // MARK: - CARD
    private func reminderCard(_ note: Note) -> some View {

        let date = note.reminderDate ?? Date()
        let isPast = date < Date()

        return VStack(alignment: .leading, spacing: 12) {

            HStack(alignment: .top, spacing: 10) {

                Image(systemName: isPast ? "exclamationmark.triangle.fill" : "alarm.fill")
                    .font(.title3)
                    .foregroundStyle(isPast ? .red : .accentColor)

                VStack(alignment: .leading, spacing: 4) {
                    Text(note.title)
                        .font(.headline)
                        .foregroundStyle(Color("PrimaryText"))

                    Text(relativeDateText(date))
                        .font(.caption)
                        .foregroundStyle(isPast ? .red : .secondary)
                }

                Spacer()

                if note.isPinned {
                    Image(systemName: "pin.fill")
                        .font(.caption)
                        .foregroundStyle(.orange)
                }
            }

            if !note.content.isEmpty {
                Text(note.content)
                    .font(.subheadline)
                    .foregroundStyle(Color("SecondaryText"))
                    .lineLimit(3)
            }

            Label(
                date.formatted(date: .abbreviated, time: .shortened),
                systemImage: "clock"
            )
            .font(.caption2)
            .foregroundStyle(.secondary)
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 18)
                .fill(
                    isPast
                    ? Color.red.opacity(colorScheme == .dark ? 0.22 : 0.14)
                    : Color("CardBackground")
                )
        )
        .overlay(
            RoundedRectangle(cornerRadius: 18)
                .stroke(Color.primary.opacity(colorScheme == .dark ? 0.12 : 0.06))
        )
        .shadow(color: shadowColor, radius: 6, x: 0, y: 4)
    }

    // MARK: - EMPTY
    private var emptyState: some View {
        VStack(spacing: 18) {
            Image(systemName: "bell.slash")
                .font(.system(size: 46))
                .foregroundStyle(.secondary)

            Text("Hatırlatma yok")
                .font(.headline)
                .foregroundStyle(Color("PrimaryText"))

            Text("Hatırlatma eklediğin notlar burada görünür")
                .font(.subheadline)
                .foregroundStyle(Color("SecondaryText"))
        }
        .padding(.top, 120)
    }

    // MARK: - HELPERS
    private func relativeDateText(_ date: Date) -> String {
        let cal = Calendar.current
        if cal.isDateInToday(date) { return "Bugün" }
        if cal.isDateInTomorrow(date) { return "Yarın" }
        if date < Date() { return "Gecikmiş" }
        return "Yaklaşan"
    }

    private var shadowColor: Color {
        colorScheme == .dark ? .black.opacity(0.35) : .black.opacity(0.12)
    }
    
    // MARK: - BANNER HELPERS

    private var bannerButtonTitle: String {

        // App-level kapalıysa
        if !notificationsEnabled {
            return "Bildirimleri Aç"
        }

        // Sistem izni hiç sorulmadıysa
        if !hasRequestedNotificationPermission {
            return "İzin Ver"
        }

        // Sistem izni reddedilmişse
        return "Ayarları Aç"
    }

    private func handleBannerAction() {

        // 🔴 APP-LEVEL KAPALI → Ayarlara gönder
        if !notificationsEnabled {
            NotificationManager.openAppSettings()
            return
        }

        // 🟡 Sistem izni daha önce sorulmadı
        if !hasRequestedNotificationPermission {

            hasRequestedNotificationPermission = true

            NotificationManager.requestAuthorization { granted in
                notificationPermissionGranted = granted

                if !granted {
                    // Sistem reddettiyse → app-level de kapat
                    notificationsEnabled = false
                }
            }
            return
        }

        // 🔴 Sistem izni reddedilmiş → Ayarlara gönder
        NotificationManager.openAppSettings()
    }



    // MARK: - FILTER LOGIC
    private var filteredReminderNotes: [Note] {
        notes
            .filter { $0.reminderDate != nil }
            .filter {
                searchText.isEmpty ||
                $0.title.localizedCaseInsensitiveContains(searchText) ||
                $0.content.localizedCaseInsensitiveContains(searchText)
            }
            .filter { note in
                switch selectedFilter {
                case .all:
                    return true
                case .overdue:
                    return note.reminderDate ?? Date() < Date()
                case .upcoming:
                    guard let date = note.reminderDate else { return false }
                    return date > Calendar.current.startOfDay(for: Date())
                }
            }
    }

    // MARK: - SECTIONS
    private enum ReminderSection: Hashable {
        case overdue, today, tomorrow, upcoming

        var title: String {
            switch self {
            case .overdue: return "Gecikmiş"
            case .today: return "Bugün"
            case .tomorrow: return "Yarın"
            case .upcoming: return "Yaklaşan"
            }
        }

        var order: Int {
            switch self {
            case .overdue: return 0
            case .today: return 1
            case .tomorrow: return 2
            case .upcoming: return 3
            }
        }
    }

    private var sectionedNotes: [ReminderSection: [Note]] {
        let cal = Calendar.current
        let now = Date()

        return Dictionary(grouping: filteredReminderNotes) { note in
            let d = note.reminderDate ?? now
            if d < now && !cal.isDateInToday(d) { return .overdue }
            if cal.isDateInToday(d) { return .today }
            if cal.isDateInTomorrow(d) { return .tomorrow }
            return .upcoming
        }
    }

    // MARK: - DATA
    private func loadNotes() {
        notes = NoteRepository.shared.fetch()
    }

    // MARK: - NOTIFICATION PERMISSION SYNC
    private func refreshSystemNotificationPermission() {
        UNUserNotificationCenter.current().getNotificationSettings { settings in
            let granted =
                settings.authorizationStatus == .authorized ||
                settings.authorizationStatus == .provisional

            DispatchQueue.main.async {
                notificationPermissionGranted = granted
            }
        }
    }
}
