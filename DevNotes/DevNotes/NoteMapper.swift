import Foundation
import CoreData

extension CDNote {

    // MARK: - CoreData → App Model
    func toNote() -> Note {

        var decodedTag: Tag? = nil
        if let data = tagData {
            decodedTag = try? JSONDecoder().decode(Tag.self, from: data)
        }

        return Note(
            id: id,
            title: title,
            content: content,
            createdAt: createdAt,
            tag: decodedTag,
            isPinned: isPinned,
            reminderDate: reminderDate
        )
    }

    // MARK: - App Model → CoreData
    static func from(
        note: Note,
        context: NSManagedObjectContext
    ) -> CDNote {

        let cd = CDNote(context: context)

        cd.id = note.id
        cd.title = note.title
        cd.content = note.content
        cd.createdAt = note.createdAt
        cd.isPinned = note.isPinned
        cd.reminderDate = note.reminderDate   // ✅ EKLENDİ

        if let tag = note.tag {
            cd.tagData = try? JSONEncoder().encode(tag)
        } else {
            cd.tagData = nil
        }

        return cd
    }
}

