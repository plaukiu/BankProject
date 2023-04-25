import UIKit

extension TransactionListViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        transactions.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(
            withIdentifier: TransactionCell.identifier,
            for: indexPath) as! TransactionCell
        
        let transaction = transactions[indexPath.item]
        
        cell.setup(data: .init(
            status: Persistence.fetchAccountId().first!.id == transaction.sendingAccountId
            ? .sender(receiver: transaction.senderPhoneNumber)
            : .receiver(sender: transaction.receiverPhoneNumber),
            date: Date(timeIntervalSince1970: (Double(transaction.transactionTime) / 1000)),
            comment: transaction.comment,
            amount: transaction.amount,
            currency: userDetails.accountInfo.currency))
        
        return cell
    }
}
