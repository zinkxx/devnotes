import SwiftUI
import UIKit

struct EditNoteView: View {

    @Environment(\.dismiss) private var dismiss
    @FocusState private var focusedField: Field?

    @State private var title: String
    @State private var plainContent: String   // RichText için

    @State private var selectedTag: Tag?
    @State private var isPinned: Bool

    // ⏰ Hatırlatma
    @State private var hasReminder: Bool
    @State private var reminderDate: Date

    let note: Note
    let onSave: (Note) -> Void

    enum Field {
        case title
    }

    // MARK: - INIT

    init(note: Note, onSave: @escaping (Note) -> Void) {
        self.note = note
        self.onSave = onSave

        _title = State(initialValue: note.title)
        _plainContent = State(initialValue: note.content)

        _selectedTag = State(initialValue: note.tag)
        _isPinned = State(initialValue: note.isPinned)

        _hasReminder = State(initialValue: note.reminderDate != nil)
        _reminderDate = State(initialValue: note.reminderDate ?? Date())
    }

    // MARK: - VIEW

    var body: some View {
        NavigationStack {
            Form {

                // MARK: Başlık
                Section("Başlık") {
                    TextField("Not başlığı", text: $title)
                        .focused($focusedField, equals: .title)
                        .submitLabel(.next)
                }

                // MARK: İçerik (RichText – İÇERİK GELİR)
                Section("İçerik") {
                    RichTextContainer(text: plainContent) { text in
                        plainContent = text
                    }
                    .frame(minHeight: 180)
                }

                // MARK: Sabitle
                Section {
                    Toggle(isOn: $isPinned) {
                        Label("Notu Sabitle", systemImage: "pin.fill")
                            .foregroundStyle(.orange)
                    }
                }

                // MARK: Hatırlatma
                Section("Hatırlatma") {
                    Toggle("Hatırlatma Ekle", isOn: $hasReminder)

                    if hasReminder {
                        DatePicker(
                            "Tarih",
                            selection: $reminderDate,
                            displayedComponents: [.date, .hourAndMinute]
                        )
                    }
                }

                // MARK: Etiket
                Section("Etiket") {
                    ForEach(TagStore.shared.tags) { tag in
                        Button {
                            selectedTag = tag
                        } label: {
                            HStack {
                                Image(systemName: tag.icon)
                                    .foregroundStyle(Color(tag.color))
                                Text(tag.name)
                                Spacer()
                                if selectedTag?.id == tag.id {
                                    Image(systemName: "checkmark")
                                        .foregroundStyle(.accent)
                                }
                            }
                        }
                    }
                }
            }
            .navigationTitle("Notu Düzenle")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {

                // ❌ İptal
                ToolbarItem(placement: .cancellationAction) {
                    Button("İptal") {
                        dismiss()
                    }
                }

                // 💾 Kaydet
                ToolbarItem(placement: .confirmationAction) {
                    Button("Kaydet") {
                        save()
                    }
                    .disabled(!canSave)
                }
            }
            .onAppear {
                focusedField = .title
            }
        }
    }

    // MARK: - SAVE

    private var canSave: Bool {
        !title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ||
        !plainContent.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    private func save() {

        let updated = Note(
            id: note.id,
            title: title.trimmingCharacters(in: .whitespacesAndNewlines),
            content: plainContent.trimmingCharacters(in: .whitespacesAndNewlines),
            createdAt: note.createdAt,
            tag: selectedTag,
            isPinned: isPinned,
            reminderDate: hasReminder ? reminderDate : nil
        )

        onSave(updated)
        dismiss()
    }
}
