import UIKit
import CoreData

struct Persistence {
    enum Operation {
        case fetch, create
    }
    enum StoredType {
        case accountId, transactions
    }
    
    static var context: NSManagedObjectContext {
        (UIApplication.shared.delegate as! AppDelegate)
            .persistentContainer
            .viewContext
    }
    
    static func fetchTransactions() -> [TransactionInfo] {
        do {
            return try context.fetch(TransactionInfo.fetchRequest())
        } catch {
            fatalError()
        }
    }
    static func fetchAccountId() -> [AccountId] {
        do {
            return try context.fetch(AccountId.fetchRequest())
        } catch {
            fatalError()
        }
    }
    static func storeAccountId(_ id: Int32) {
        do {
            let newAccountId = AccountId(context: context)
            newAccountId.id = id
            try context.save()
        } catch {
            fatalError()
        }
    }
    static func clear() {
        fetchAccountId()
            .forEach {
                context.delete($0)
            }
        fetchTransactions()
            .forEach {
                context.delete($0)
            }
    }
    
    @discardableResult
    static func storeTransactions(_ transactions: [Service.TransactionInfo]) -> [TransactionInfo] {
        
        let new = transactions.map {
            let transaction = TransactionInfo(context: context)
            transaction.sendingAccountId = $0.sendingAccountId
            transaction.senderPhoneNumber = $0.senderPhoneNumber
            transaction.receivingAccountId = $0.receivingAccountId
            transaction.receiverPhoneNumber = $0.receiverPhoneNumber
            transaction.transactionTime = Int64($0.transactionTime)
            transaction.comment = $0.comment
            transaction.amount = $0.amount
            return transaction
        }
        
        do {
            try context.save()
        } catch {
            fatalError()
        }
        return new
    }
}
