import Foundation
import CoreData

extension CDNote {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<CDNote> {
        NSFetchRequest<CDNote>(entityName: "CDNote")
    }

    @NSManaged public var id: UUID
    @NSManaged public var title: String
    @NSManaged public var content: String
    @NSManaged public var createdAt: Date
    @NSManaged public var tagData: Data?
    @NSManaged public var isPinned: Bool
    @NSManaged public var reminderDate: Date?
}
