import SwiftUI

struct RemindersView: View {

    // MARK: - STATE
    @State private var notes: [Note] = []
    @State private var searchText = ""

    @Environment(\.colorScheme) private var colorScheme

    // MARK: - BODY
    var body: some View {
        NavigationStack {
            ZStack {
                Color("AppBackground")
                    .ignoresSafeArea()

                content
            }
            .navigationBarTitleDisplayMode(.inline)
            .searchable(text: $searchText, prompt: "Hatırlatmalarda ara")
            .toolbar {
                // 🔔 ICON + TITLE
                ToolbarItem(placement: .principal) {
                    HStack(spacing: 8) {
                        Image(systemName: "alarm.fill")
                            .foregroundStyle(.red)

                        Text("Hatırlatmalar")
                            .font(.headline)
                            .foregroundStyle(Color("PrimaryText"))
                    }
                }

                // 🔄 REFRESH
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        loadNotes()
                    } label: {
                        Image(systemName: "arrow.clockwise")
                    }
                }
            }
            .onAppear { loadNotes() }
        }
    }

    // MARK: - CONTENT
    @ViewBuilder
    private var content: some View {
        if filteredReminderNotes.isEmpty {
            emptyState
        } else {
            ScrollView {
                LazyVStack(spacing: 14) {
                    ForEach(filteredReminderNotes) { note in
                        NavigationLink {
                            EditNoteView(note: note) { _ in
                                loadNotes()
                            }
                        } label: {
                            reminderCard(note)
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(.horizontal)
                .padding(.top, 12)
            }
        }
    }

    // MARK: - CARD
    private func reminderCard(_ note: Note) -> some View {

        let date = note.reminderDate ?? Date()
        let isPast = date < Date()

        return VStack(alignment: .leading, spacing: 12) {

            // HEADER
            HStack(alignment: .top, spacing: 10) {

                Image(systemName: isPast
                      ? "exclamationmark.triangle.fill"
                      : "alarm.fill")
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

            // CONTENT
            if !note.content.isEmpty {
                Text(note.content)
                    .font(.subheadline)
                    .foregroundStyle(Color("SecondaryText"))
                    .lineLimit(3)
            }

            // FOOTER
            Label(
                date.formatted(date: .abbreviated, time: .shortened),
                systemImage: "clock"
            )
            .font(.caption2)
            .foregroundStyle(.secondary)
        }
        .padding(16)
        .background(cardBackground(isPast: isPast))
        .overlay(cardBorder)
        .shadow(color: shadowColor, radius: 6, x: 0, y: 4)
    }

    // MARK: - HELPERS
    private func relativeDateText(_ date: Date) -> String {
        let cal = Calendar.current

        if cal.isDateInToday(date) {
            return "Bugün"
        } else if cal.isDateInTomorrow(date) {
            return "Yarın"
        } else if date < Date() {
            return "Gecikmiş"
        } else {
            return "Yaklaşan"
        }
    }

    // MARK: - STYLES
    private func cardBackground(isPast: Bool) -> some View {
        RoundedRectangle(cornerRadius: 18)
            .fill(
                isPast
                ? Color.red.opacity(colorScheme == .dark ? 0.22 : 0.14)
                : Color("CardBackground")
            )
    }

    private var cardBorder: some View {
        RoundedRectangle(cornerRadius: 18)
            .stroke(
                Color.primary.opacity(colorScheme == .dark ? 0.12 : 0.06),
                lineWidth: 1
            )
    }

    private var shadowColor: Color {
        colorScheme == .dark
        ? .black.opacity(0.35)
        : .black.opacity(0.12)
    }

    // MARK: - EMPTY STATE
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

    // MARK: - FILTERS
    private var filteredReminderNotes: [Note] {
        notes
            .filter { $0.reminderDate != nil }
            .filter {
                searchText.isEmpty ||
                $0.title.localizedCaseInsensitiveContains(searchText) ||
                $0.content.localizedCaseInsensitiveContains(searchText)
            }
            .sorted {
                ($0.reminderDate ?? .distantFuture) <
                ($1.reminderDate ?? .distantFuture)
            }
    }

    // MARK: - DATA
    private func loadNotes() {
        notes = NoteRepository.shared.fetch()
    }
}
