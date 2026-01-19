import Foundation

struct Note: Identifiable, Codable, Equatable {
    let id: UUID
    var title: String
    var content: String
    var createdAt: Date
    var tag: Tag?
    var isPinned: Bool   // 🆕
    var reminderDate: Date?
}
