import Foundation
import Combine

final class NoteStore: ObservableObject {

    static let shared = NoteStore()
    private init() {}

    @Published var notes: [Note] = []
}
