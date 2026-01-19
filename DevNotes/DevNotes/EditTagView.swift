import SwiftUI

struct EditTagView: View {

    @Environment(\.dismiss) private var dismiss

    @State private var name: String
    @State private var icon: String
    @State private var color: String

    let tag: Tag

    // MARK: - Init
    init(tag: Tag) {
        self.tag = tag
        _name = State(initialValue: tag.name)
        _icon = State(initialValue: tag.icon)
        _color = State(initialValue: tag.color)
    }

    // MARK: - View
    var body: some View {
        NavigationStack {
            Form {

                // MARK: - Önizleme
                Section {
                    HStack(spacing: 12) {
                        Image(systemName: icon)
                            .font(.title2)
                            .foregroundStyle(Color(color))

                        Text(name.isEmpty ? "Etiket Adı" : name)
                            .font(.headline)
                            .foregroundStyle(Color(color))

                        Spacer()
                    }
                    .padding(.vertical, 6)
                }

                // MARK: - Etiket Adı
                Section("Etiket Adı") {
                    TextField("Etiket adı", text: $name)
                }

                // MARK: - İkon Seçimi
                Section("İkon") {
                    LazyVGrid(columns: Array(repeating: .init(.flexible()), count: 5)) {
                        ForEach(TagAssets.icons, id: \.self) { item in
                            Button {
                                icon = item
                            } label: {
                                Image(systemName: item)
                                    .font(.title3)
                                    .frame(width: 44, height: 44)
                                    .foregroundStyle(item == icon ? .white : .primary)
                                    .background(
                                        Circle()
                                            .fill(
                                                item == icon
                                                ? Color(color)
                                                : Color.secondary.opacity(0.15)
                                            )
                                    )
                            }
                            .buttonStyle(.plain)
                        }
                    }
                    .padding(.vertical, 4)
                }

                // MARK: - Renk Seçimi
                Section("Renk") {
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 12) {
                            ForEach(TagAssets.colors, id: \.key) { item in
                                Button {
                                    color = item.key
                                } label: {
                                    Circle()
                                        .fill(Color(item.key))
                                        .frame(width: 28, height: 28)
                                        .overlay(
                                            Circle()
                                                .stroke(
                                                    color == item.key
                                                    ? Color.primary
                                                    : .clear,
                                                    lineWidth: 2
                                                )
                                        )
                                }
                                .buttonStyle(.plain)
                                .accessibilityLabel(item.name)
                            }
                        }
                        .padding(.vertical, 4)
                    }
                }

                // MARK: - Silme
                Section {
                    DeleteTagButton(tag: tag)
                }
            }
            .navigationTitle("Etiketi Düzenle")
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
        }
    }

    // MARK: - Validation
    private var canSave: Bool {
        let trimmed = name.trimmingCharacters(in: .whitespacesAndNewlines)
        return !trimmed.isEmpty &&
        !TagStore.shared.isNameDuplicate(trimmed, excluding: tag.id)
    }

    // MARK: - Save
    private func save() {
        let updated = Tag(
            id: tag.id,
            name: name.trimmingCharacters(in: .whitespacesAndNewlines),
            color: color,
            icon: icon
        )
        TagStore.shared.update(updated)
        dismiss()
    }
}
