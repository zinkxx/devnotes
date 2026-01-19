import SwiftUI

struct PinnedNotesView: View {

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
            .searchable(text: $searchText, prompt: "Sabitlenenlerde ara")
            .toolbar {
                ToolbarItem(placement: .principal) {
                    HStack(spacing: 8) {
                        Image(systemName: "pin.fill")
                            .foregroundStyle(.orange)

                        Text("Sabitlenenler")
                            .font(.headline)
                            .foregroundStyle(Color("PrimaryText"))
                    }
                }
            }
            .onAppear { loadNotes() }
        }
    }

    // MARK: - CONTENT
    @ViewBuilder
    private var content: some View {
        if filteredPinnedNotes.isEmpty {
            emptyState
        } else {
            ScrollView {
                LazyVStack(spacing: 14) {
                    ForEach(filteredPinnedNotes) { note in
                        NavigationLink {
                            EditNoteView(note: note) { _ in
                                loadNotes()
                            }
                        } label: {
                            pinnedCard(note)
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
    private func pinnedCard(_ note: Note) -> some View {
        VStack(alignment: .leading, spacing: 12) {

            // HEADER
            HStack(alignment: .top, spacing: 10) {

                Image(systemName: "pin.fill")
                    .font(.title3)
                    .foregroundStyle(.orange)

                VStack(alignment: .leading, spacing: 4) {
                    Text(note.title)
                        .font(.headline)
                        .foregroundStyle(Color("PrimaryText"))

                    if let date = note.reminderDate {
                        Label(
                            date.formatted(date: .abbreviated, time: .shortened),
                            systemImage: "alarm.fill"
                        )
                        .font(.caption)
                        .foregroundStyle(.red)
                    }
                }

                Spacer()
            }

            // CONTENT
            if !note.content.isEmpty {
                Text(note.content)
                    .font(.subheadline)
                    .foregroundStyle(Color("SecondaryText"))
                    .lineLimit(3)
            }

            // FOOTER
            HStack {
                if let tag = note.tag {
                    Label(tag.name, systemImage: tag.icon)
                        .font(.caption2)
                        .foregroundStyle(Color(tag.color))
                }

                Spacer()

                Text(note.createdAt, style: .date)
                    .font(.caption2)
                    .foregroundStyle(.secondary)
            }
        }
        .padding(16)
        .background(cardBackground(note))
        .overlay(cardBorder)
        .shadow(color: shadowColor, radius: 6, x: 0, y: 4)
    }

    // MARK: - STYLES
    private func cardBackground(_ note: Note) -> some View {
        RoundedRectangle(cornerRadius: 18)
            .fill(
                Color.orange.opacity(colorScheme == .dark ? 0.18 : 0.12)
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
            Image(systemName: "pin.slash")
                .font(.system(size: 46))
                .foregroundStyle(.secondary)

            Text("Sabitlenmiş not yok")
                .font(.headline)
                .foregroundStyle(Color("PrimaryText"))

            Text("Sabitlediğin notlar burada görünür")
                .font(.subheadline)
                .foregroundStyle(Color("SecondaryText"))
        }
        .padding(.top, 120)
    }

    // MARK: - FILTERS
    private var filteredPinnedNotes: [Note] {
        notes
            .filter { $0.isPinned }
            .filter {
                searchText.isEmpty ||
                $0.title.localizedCaseInsensitiveContains(searchText) ||
                $0.content.localizedCaseInsensitiveContains(searchText)
            }
    }

    // MARK: - DATA
    private func loadNotes() {
        notes = NoteRepository.shared.fetch()
    }
}
