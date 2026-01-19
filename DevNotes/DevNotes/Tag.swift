import Foundation

struct Tag: Identifiable, Codable, Equatable {
    let id: UUID
    var name: String
    var color: String      // Asset color name
    var icon: String       // SF Symbol name

    static let sample: [Tag] = [
        Tag(id: UUID(), name: "İş", color: "TagBlue", icon: "briefcase.fill"),
        Tag(id: UUID(), name: "Kişisel", color: "TagGreen", icon: "person.fill"),
        Tag(id: UUID(), name: "Fikir", color: "TagPurple", icon: "lightbulb.fill")
    ]
}
