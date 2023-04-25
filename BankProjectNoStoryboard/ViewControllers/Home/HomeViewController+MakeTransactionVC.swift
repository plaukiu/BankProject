import UIKit

extension HomeViewController {
    var makeTransactionViewController: UIAlertController {
        
        let view = UIAlertController(title: "Make Transaction",
                                     message: nil,
                                     preferredStyle: .alert)
        
        view.addTextField { textField in
            textField.placeholder = "Recipient phone number"
            textField.keyboardType = .phonePad
        }
        view.addTextField { textField in
            textField.placeholder = "Currency"
        }
        view.addTextField { textField in
            textField.placeholder = "Comment"
        }
        view.addTextField { textField in
            textField.placeholder = "Sum"
            textField.keyboardType = .numberPad
        }
        
        view.addAction(.init(title: "Send", style: .default) { [unowned self] _ in
            let recipientField = view.textFields![0]
            let currencyField = view.textFields![1]
            let commentField = view.textFields![2]
            let sumField = view.textFields![3]
            
            guard let recipient = recipientField.text,
//                  let currency = currencyField.text,
                  let comment = commentField.text,
                  let sumString = sumField.text else {
                fatalError("Fields doesn't work")
            }
            guard let sum = Double(sumString) else {
                fatalError("String->Double conversion didn't work")
            }
            
            let request = Service.TransactionRequest.init(
                senderPhoneNumber: userDetails.accountInfo.ownerPhoneNumber,
                token: userDetails.accessToken,
                receiverPhoneNumber: recipient,
                senderAccountId: userDetails.accountInfo.id,
                amount: sum,
                comment: comment)
            
            ServiceWrapper
                .makeTransaction(transactionRequest: request, receiver: self)
                .makeRequest()
                
        })
        
        view.addAction(.init(title: "Cancel", style: .cancel) {_ in
            view.dismiss(animated: true)
        })
        
        return view
    }
}

extension HomeViewController: TransactionSuccessReceiver {
    func receiveTransactionSuccess() {
        transactionTableView.reloadData()
        
    }
}
