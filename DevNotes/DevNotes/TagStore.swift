import Foundation
import Combine

final class TagStore: ObservableObject {

    // MARK: - Singleton
    static let shared = TagStore()
    private init() {}

    // MARK: - Published Tags
    @Published var tags: [Tag] = [

        Tag(
            id: UUID(uuidString: "11111111-1111-1111-1111-111111111111")!,
            name: "İş",
            color: "TagBlue",
            icon: "briefcase.fill"
        ),

        Tag(
            id: UUID(uuidString: "22222222-2222-2222-2222-222222222222")!,
            name: "Kişisel",
            color: "TagGreen",
            icon: "person.fill"
        ),

        Tag(
            id: UUID(uuidString: "33333333-3333-3333-3333-333333333333")!,
            name: "Fikir",
            color: "TagPurple",
            icon: "lightbulb.fill"
        ),

        Tag(
            id: UUID(uuidString: "44444444-4444-4444-4444-444444444444")!,
            name: "Acil",
            color: "TagOrange",
            icon: "exclamationmark.triangle.fill"
        ),

        Tag(
            id: UUID(uuidString: "55555555-5555-5555-5555-555555555555")!,
            name: "Hata",
            color: "TagRed",
            icon: "ant.fill"
        ),

        Tag(
            id: UUID(uuidString: "66666666-6666-6666-6666-666666666666")!,
            name: "Öğrenme",
            color: "TagYellow",
            icon: "book.fill"
        ),

        Tag(
            id: UUID(uuidString: "77777777-7777-7777-7777-777777777777")!,
            name: "Araştırma",
            color: "TagTeal",
            icon: "magnifyingglass.circle.fill"
        )
    ]

    // MARK: - Public API

    /// Yeni etiket ekle
    func add(_ tag: Tag) {
        tags.append(tag)
    }

    /// Etiket güncelle
    func update(_ tag: Tag) {
        guard let index = tags.firstIndex(where: { $0.id == tag.id }) else { return }
        tags[index] = tag
    }

    /// Etiket sil
    func delete(_ tag: Tag) {
        tags.removeAll { $0.id == tag.id }
    }

    // MARK: - Validation

    /// Aynı isimde etiket var mı?
    /// - Parameters:
    ///   - name: kontrol edilecek isim
    ///   - excluding: edit sırasında hariç tutulacak id
    func isNameDuplicate(_ name: String, excluding excludingID: UUID? = nil) -> Bool {

        let normalized = normalize(name)

        return tags.contains { tag in
            tag.id != excludingID &&
            normalize(tag.name) == normalized
        }
    }

    // MARK: - Helpers

    /// Etikete bağlı not sayısı
    /// UI tarafında silme uyarısında kullanılır
    func linkedNotesCount(for tag: Tag) -> Int {
        NoteStore.shared.notes.filter {
            $0.tag?.id == tag.id
        }.count
    }

    /// İsim normalize (trim + lowercase)
    private func normalize(_ value: String) -> String {
        value
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .lowercased()
    }
}
