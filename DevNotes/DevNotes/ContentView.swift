import SwiftUI

struct ContentView: View {

    // MARK: - STATE
    @State private var notes: [Note] = []
    @State private var showAddNote = false
    @State private var searchText = ""
    @State private var selectedTag: Tag? = nil
    @State private var shareNote: Note?

    @Environment(\.colorScheme) private var colorScheme

    var body: some View {
        NavigationStack {
            ZStack {
                Color("AppBackground")
                    .ignoresSafeArea()

                content
            }
            .navigationBarTitleDisplayMode(.inline)
            .searchable(text: $searchText, prompt: "Notlarda ara")
            .toolbar {
                ToolbarItem(placement: .principal) {
                    HStack(spacing: 8) {
                        Image(systemName: "note.text")
                            .foregroundStyle(.orange)

                        Text("Notlar")
                            .font(.headline)
                            .foregroundStyle(Color("PrimaryText"))
                    }
                }

                toolbarContent
            }
            .sheet(isPresented: $showAddNote) {
                AddNoteView { addNote($0) }
            }
            .sheet(item: $shareNote) { note in
                ShareSheet(items: ["\(note.title)\n\n\(note.content)"])
            }
            .onAppear { loadNotes() }
        }

    }

    // MARK: - CONTENT

    @ViewBuilder
    private var content: some View {
        if notes.isEmpty {
            EmptyStateView()
        } else if filteredNotes.isEmpty {
            emptyResultView
        } else {
            List {

                // 📌 PINNED
                if !pinnedNotes.isEmpty {
                    Section {
                        ForEach(pinnedNotes) { note in
                            noteRow(note)
                        }
                    } header: {
                        sectionHeader(
                            title: "Sabitlenenler",
                            icon: "pin.fill",
                            color: .orange
                        )
                    }
                }

                // 📝 NORMAL
                ForEach(unpinnedNotes) { note in
                    noteRow(note)
                }
            }
            .listStyle(.plain)
            .scrollContentBackground(.hidden)
        }
    }

    // MARK: - NOTE ROW

    private func noteRow(_ note: Note) -> some View {
        NavigationLink {
            EditNoteView(
                note: note,
                onSave: { updateNote($0) },
                onDelete: { deleteNoteDirect($0) }
            )
        } label: {
            noteCard(note)
        }
        .buttonStyle(.plain)
        .listRowSeparator(.hidden)
        .listRowBackground(Color.clear)

        // 👉 SAĞA ÇEK — SABİTLE
        .swipeActions(edge: .leading, allowsFullSwipe: false) {
            Button {
                togglePin(note)
            } label: {
                Label(
                    note.isPinned ? "Sabiti Kaldır" : "Sabitle",
                    systemImage: note.isPinned ? "pin.slash.fill" : "pin.fill"
                )
            }
            .tint(.orange)
        }

        // 👈 SOLA ÇEK — SİL
        .swipeActions(edge: .trailing, allowsFullSwipe: true) {
            Button(role: .destructive) {
                deleteNoteDirect(note)
            } label: {
                Label("Sil", systemImage: "trash.fill")
            }
        }

        // 📋 CONTEXT MENU
        .contextMenu {
            Button {
                togglePin(note)
            } label: {
                Label(
                    note.isPinned ? "Sabitlemeyi Kaldır" : "Sabitle",
                    systemImage: note.isPinned ? "pin.slash" : "pin"
                )
            }

            Button {
                shareNote = note
            } label: {
                Label("Paylaş", systemImage: "square.and.arrow.up")
            }

            Button(role: .destructive) {
                deleteNoteDirect(note)
            } label: {
                Label("Sil", systemImage: "trash")
            }
        }
    }

    // MARK: - NOTE CARD

    private func noteCard(_ note: Note) -> some View {
        VStack(alignment: .leading, spacing: 12) {

            // 🏷️ TAG
            if let tag = note.tag {
                HStack(spacing: 6) {
                    Image(systemName: tag.icon)
                    Text(tag.name)
                }
                .font(.caption)
                .foregroundStyle(Color(tag.color))
            }

            // 📝 TITLE + ICONS
            HStack(alignment: .top) {
                Text(note.title)
                    .font(.headline)
                    .foregroundStyle(Color("PrimaryText"))

                Spacer()

                if note.reminderDate != nil {
                    Image(systemName: "alarm.fill")
                        .font(.caption)
                        .foregroundStyle(.red)
                }

                if note.isPinned {
                    Image(systemName: "pin.fill")
                        .font(.caption)
                        .foregroundStyle(.orange)
                }
            }

            // 📄 CONTENT
            if !note.content.isEmpty {
                Text(note.content)
                    .font(.subheadline)
                    .foregroundStyle(Color("SecondaryText"))
                    .lineLimit(3)
            }

            // 📅 FOOTER
            Text(note.createdAt, style: .date)
                .font(.caption2)
                .foregroundStyle(.secondary)
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
                note.reminderDate != nil
                ? Color.red.opacity(colorScheme == .dark ? 0.22 : 0.14)
                : note.isPinned
                    ? Color.orange.opacity(colorScheme == .dark ? 0.18 : 0.12)
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

    // MARK: - SECTION HEADER

    private func sectionHeader(
        title: String,
        icon: String,
        color: Color
    ) -> some View {
        HStack(spacing: 6) {
            Image(systemName: icon)
            Text(title)
        }
        .font(.caption)
        .foregroundStyle(color)
        .padding(.vertical, 6)
    }

    // MARK: - EMPTY RESULT

    private var emptyResultView: some View {
        VStack(spacing: 14) {
            Image(systemName: "magnifyingglass")
                .font(.system(size: 42))
                .foregroundStyle(.secondary)

            Text("Sonuç bulunamadı")
                .font(.headline)
                .foregroundStyle(Color("PrimaryText"))

            Text("Farklı bir arama veya etiket deneyin")
                .font(.subheadline)
                .foregroundStyle(Color("SecondaryText"))
        }
        .padding(.top, 100)
    }

    // MARK: - TOOLBAR

    @ToolbarContentBuilder
    private var toolbarContent: some ToolbarContent {
        ToolbarItem(placement: .topBarLeading) {
            TagFilterMenu(
                tags: TagStore.shared.tags,
                selectedTag: $selectedTag
            )
        }

        ToolbarItem(placement: .topBarLeading) {
            NavigationLink { TagManagerView() } label: {
                Image(systemName: "tag")
            }
        }

        ToolbarItem(placement: .topBarTrailing) {
            Button {
                showAddNote = true
            } label: {
                Image(systemName: "plus")
            }
        }
    }

    // MARK: - FILTERS

    private var filteredNotes: [Note] {
        var result = notes

        if !searchText.isEmpty {
            result = result.filter {
                $0.title.localizedCaseInsensitiveContains(searchText) ||
                $0.content.localizedCaseInsensitiveContains(searchText)
            }
        }

        if let tag = selectedTag {
            result = result.filter { $0.tag?.name == tag.name }
        }

        return result
    }

    private var pinnedNotes: [Note] {
        filteredNotes.filter { $0.isPinned }
    }

    private var unpinnedNotes: [Note] {
        filteredNotes.filter { !$0.isPinned }
    }

    // MARK: - DATA

    private func loadNotes() {
        notes = NoteRepository.shared.fetch()
    }

    private func addNote(_ note: Note) {
        NoteRepository.shared.add(note)
        loadNotes()
    }

    private func updateNote(_ updated: Note) {
        NoteRepository.shared.update(updated)
        loadNotes()
    }

    private func togglePin(_ note: Note) {
        NoteRepository.shared.togglePin(note)
        loadNotes()
    }

    private func deleteNoteDirect(_ note: Note) {
        NoteRepository.shared.delete(note)
        loadNotes()
    }
}
