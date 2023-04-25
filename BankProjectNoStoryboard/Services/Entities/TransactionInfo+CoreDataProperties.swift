import Foundation
import CoreData


extension TransactionInfo {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<TransactionInfo> {
        return NSFetchRequest<TransactionInfo>(entityName: "TransactionInfo")
    }

    @NSManaged public var senderPhoneNumber: String
    @NSManaged public var receiverPhoneNumber: String
    @NSManaged public var sendingAccountId: Int32
    @NSManaged public var receivingAccountId: Int32
    @NSManaged public var transactionTime: Int64
    @NSManaged public var amount: Double
    @NSManaged public var comment: String
    @NSManaged public var transactionAccount: AccountId?

}

extension TransactionInfo : Identifiable {

}
