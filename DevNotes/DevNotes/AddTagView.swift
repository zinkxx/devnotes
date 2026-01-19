import SwiftUI

struct AddTagView: View {

    @Environment(\.dismiss) private var dismiss

    @State private var name = ""
    @State private var icon = "tag.fill"
    @State private var color = "TagBlue"

    private let icons = [

        // Genel
        "tag.fill",
        "bookmark.fill",
        "star.fill",
        "heart.fill",
        "flag.fill",

        // İş / Üretkenlik
        "briefcase.fill",
        "calendar",
        "checkmark.circle.fill",
        "chart.bar.fill",
        "doc.text.fill",
        "folder.fill",

        // Kişisel / Sosyal
        "person.fill",
        "person.2.fill",
        "bubble.left.and.bubble.right.fill",
        "phone.fill",

        // Fikir / Eğitim
        "lightbulb.fill",
        "book.fill",
        "graduationcap.fill",
        "pencil.tip",

        // Teknoloji
        "bolt.fill",
        "gearshape.fill",
        "desktopcomputer",
        "terminal.fill",

        // Sağlık / Yaşam
        "heart.text.square.fill",
        "leaf.fill",
        "bed.double.fill",
        "figure.walk",

        // Eğlence / Hobi
        "music.note",
        "gamecontroller.fill",
        "camera.fill",
        "film.fill"
    ]


    private let colors: [(key: String, name: String)] = [

        // Temel
        ("TagBlue", "Mavi"),
        ("TagGreen", "Yeşil"),
        ("TagPurple", "Mor"),
        ("TagOrange", "Turuncu"),
        ("TagRed", "Kırmızı"),

        // Ek – Soft
        ("TagTeal", "Turkuaz"),
        ("TagMint", "Mint"),
        ("TagIndigo", "Indigo"),

        // Ek – Canlı
        ("TagPink", "Pembe"),
        ("TagYellow", "Sarı"),
        ("TagCyan", "Camgöbeği"),

        // Koyu / Premium
        ("TagBrown", "Kahverengi"),
        ("TagGray", "Gri"),
        ("TagBlack", "Siyah")
    ]

    var body: some View {
        NavigationStack {
            Form {

                // MARK: - Önizleme
                Section {
                    HStack(spacing: 12) {
                        Image(systemName: icon)
                            .foregroundStyle(Color(color))
                            .font(.title2)

                        Text(name.isEmpty ? "Etiket Adı" : name)
                            .font(.headline)
                            .foregroundStyle(Color(color))

                        Spacer()
                    }
                    .padding(.vertical, 6)
                } header: {
                    Text("Önizleme")
                }

                // MARK: - Etiket Adı
                Section("Etiket Adı") {
                    TextField("Örn: İş, Kişisel, Fikir", text: $name)
                }

                // MARK: - İkon Seçimi
                Section("İkon") {
                    LazyVGrid(columns: Array(repeating: .init(.flexible()), count: 5)) {
                        ForEach(icons, id: \.self) { item in
                            Button {
                                icon = item
                            } label: {
                                Image(systemName: item)
                                    .font(.title3)
                                    .frame(width: 44, height: 44)
                                    .foregroundStyle(item == icon ? .white : .primary)
                                    .background(
                                        Circle()
                                            .fill(item == icon ? Color(color) : Color.secondary.opacity(0.15))
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
                            ForEach(colors, id: \.key) { item in
                                Button {
                                    color = item.key
                                } label: {
                                    Circle()
                                        .fill(Color(item.key))
                                        .frame(width: 28, height: 28)
                                        .overlay(
                                            Circle()
                                                .stroke(
                                                    color == item.key ? Color.primary : .clear,
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

            }
            .navigationTitle("Yeni Etiket")
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

    // MARK: - Helpers

    private var canSave: Bool {
        !name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    private func save() {
        let trimmedName = name.trimmingCharacters(in: .whitespacesAndNewlines)

        TagStore.shared.add(
            Tag(
                id: UUID(),
                name: trimmedName,
                color: color,
                icon: icon
            )
        )
        dismiss()
    }
}
