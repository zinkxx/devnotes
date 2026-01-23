import Foundation

struct Tag: Identifiable, Codable, Equatable {

    // MARK: - Core Properties
    let id: UUID
    var name: String
    var color: String      // Asset color name (ör: "TagBlue")
    var icon: String       // SF Symbol name (ör: "briefcase.fill")

    // MARK: - Init
    init(
        id: UUID = UUID(),
        name: String,
        color: String,
        icon: String
    ) {
        self.id = id
        self.name = name
        self.color = color
        self.icon = icon
    }

    // MARK: - Preview / Sample (UI & SwiftUI Preview için)
    static let samples: [Tag] = [
        Tag(name: "İş", color: "TagBlue", icon: "briefcase.fill"),
        Tag(name: "Kişisel", color: "TagGreen", icon: "person.fill"),
        Tag(name: "Fikir", color: "TagPurple", icon: "lightbulb.fill")
    ]
}
