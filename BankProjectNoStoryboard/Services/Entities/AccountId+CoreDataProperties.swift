import Foundation
import CoreData


extension AccountId {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<AccountId> {
        return NSFetchRequest<AccountId>(entityName: "AccountId")
    }

    @NSManaged public var id: Int32

}

extension AccountId : Identifiable {

}
