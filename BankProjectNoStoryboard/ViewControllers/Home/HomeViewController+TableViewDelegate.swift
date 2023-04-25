import UIKit

extension HomeViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        transactions.count <= 5
        ? transactions.count
        : 5
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(
            withIdentifier: TransactionCell.identifier,
            for: indexPath) as! TransactionCell
        
        let transaction = transactions[transactions.count - 1 - indexPath.item]
        
        cell.setup(data: .init(
            status: userDetails.accountInfo.ownerPhoneNumber == transaction.senderPhoneNumber
            ? .sender(receiver: transaction.receiverPhoneNumber)
            : .receiver(sender: transaction.senderPhoneNumber),
            date: Date(timeIntervalSince1970: (Double(transaction.transactionTime) / 1000)),
            comment: transaction.comment,
            amount: transaction.amount,
            currency: userDetails.accountInfo.currency))
        
        return cell
    }
}

