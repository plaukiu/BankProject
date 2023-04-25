import UIKit

extension HomeViewController {
    var addMoneyViewController: UIAlertController {
        
        let view = UIAlertController(title: "Add money to your account",
                                     message: nil,
                                     preferredStyle: .alert)
        
        view.addTextField { textField in
            textField.placeholder = "amount to add..."
            textField.keyboardType = .decimalPad
        }
        
        view.addAction(.init(title: "OK", style: .default) { [unowned self] _ in
            guard let amountString = view.textFields![0].text,
                  !amountString.isEmpty,
                  let amount = Int(amountString)
            else { return }
            
            ServiceWrapper
                .updateBalance(
                    accountId: userDetails.accountInfo.id,
                    amountToAdd: amount,
                    receiver: self)
                .makeRequest()
        })
        view.addAction(.init(title: "Cancel", style: .cancel))

        return view
    }
}

extension HomeViewController: AccountInfoReceiver {
    func receive(accountInfo new: Service.AccountInfo) {
        authenticationResponse.accountInfo = new
        redrawBalanceLabel()
        updateLayout()
    }
}
