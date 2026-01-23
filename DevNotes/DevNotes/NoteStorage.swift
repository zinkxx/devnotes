import Foundation
import Combine

final class NoteStorage {

    private static let key = "devnotes.notes"

    static func save(_ notes: [Note]) {
        if let data = try? JSONEncoder().encode(notes) {
            UserDefaults.standard.set(data, forKey: key)
        }
    }

    static func load() -> [Note] {
        guard
            let data = UserDefaults.standard.data(forKey: key),
            let notes = try? JSONDecoder().decode([Note].self, from: data)
        else {
            return []
        }

        return notes
    }
}
