import CoreData

final class NoteRepository {

    // MARK: - Singleton
    static let shared = NoteRepository()
    private init() {}

    // MARK: - CoreData Context
    private let context = PersistenceController.shared.container.viewContext

    // MARK: - Fetch (Pinli notlar üstte)

    func fetch() -> [Note] {
        let request: NSFetchRequest<CDNote> = CDNote.fetchRequest()

        request.sortDescriptors = [
            NSSortDescriptor(key: "isPinned", ascending: false),
            NSSortDescriptor(key: "createdAt", ascending: false)
        ]

        do {
            let result = try context.fetch(request)
            return result.map { $0.toNote() }
        } catch {
            print("❌ Fetch error:", error)
            return []
        }
    }

    // MARK: - Add

    func add(_ note: Note) {
        _ = CDNote.from(note: note, context: context)
        save()
    }

    // MARK: - Update (Başlık, içerik, tag, pin)

    func update(_ note: Note) {
        let request: NSFetchRequest<CDNote> = CDNote.fetchRequest()
        request.predicate = NSPredicate(format: "id == %@", note.id as CVarArg)

        guard let cd = try? context.fetch(request).first else { return }

        cd.title = note.title
        cd.content = note.content
        cd.createdAt = note.createdAt
        cd.isPinned = note.isPinned

        // 🔔 HATIRLATMA (BU EKSİKTİ)
        cd.reminderDate = note.reminderDate

        // 🏷️ TAG
        if let tag = note.tag {
            cd.tagData = try? JSONEncoder().encode(tag)
        } else {
            cd.tagData = nil
        }

        save()
    }

    // MARK: - Toggle Pin

    func togglePin(_ note: Note) {
        let request: NSFetchRequest<CDNote> = CDNote.fetchRequest()
        request.predicate = NSPredicate(format: "id == %@", note.id as CVarArg)

        guard let cd = try? context.fetch(request).first else { return }

        cd.isPinned.toggle()
        save()
    }

    // MARK: - Delete Single Note

    func delete(_ note: Note) {
        let request: NSFetchRequest<CDNote> = CDNote.fetchRequest()
        request.predicate = NSPredicate(format: "id == %@", note.id as CVarArg)

        if let cd = try? context.fetch(request).first {
            context.delete(cd)
            save()
        }
    }

    // MARK: - Delete ALL Notes (⚠️ SettingsView için)

    func deleteAll() {
        let request: NSFetchRequest<NSFetchRequestResult> = CDNote.fetchRequest()
        let batchDelete = NSBatchDeleteRequest(fetchRequest: request)
        batchDelete.resultType = .resultTypeObjectIDs

        do {
            let result = try context.execute(batchDelete) as? NSBatchDeleteResult
            let objectIDs = result?.result as? [NSManagedObjectID] ?? []

            // Context’i senkronla (çok önemli)
            let changes: [AnyHashable: Any] = [
                NSDeletedObjectsKey: objectIDs
            ]
            NSManagedObjectContext.mergeChanges(
                fromRemoteContextSave: changes,
                into: [context]
            )

        } catch {
            print("❌ deleteAll error:", error)
        }
    }

    // MARK: - Save Context

    private func save() {
        guard context.hasChanges else { return }

        do {
            try context.save()
        } catch {
            print("❌ CoreData save error:", error)
        }
    }
}
