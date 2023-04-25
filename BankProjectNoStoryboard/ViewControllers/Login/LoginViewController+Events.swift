import UIKit

extension LoginViewController {
    func submit() {
        guard let phoneNumber = self.phoneNumberField.text,
              let password = self.passwordField.text else { return }
        
        
        
        switch self.state {
        case .login:
            let request = ServiceWrapper
                .login(phoneNumber: phoneNumber,
                       password: password,
                       receiver: self)
            
            TokenUpdater.shared.set(request: request.rawValue)
            request.makeRequest()
            
        case .register:
            guard let currency = self.currencyField.text,
                  let confirm = self.confirmField.text,
                  confirm == password else { return }

            ServiceWrapper
                .register(phoneNumber: phoneNumber,
                          password: password,
                          currency: currency,
                          receiver: self)
                .makeRequest()
        }
    }
}

extension LoginViewController:
    UserAuthenticationResponseReceiver,
    UserRegisterResponseReceiver,
    TransactionInfoReceiver
{
    func receive(userAuthenticationResponse response: Service.UserAuthenticationResponse) {
        Persistence.clear()
        Persistence.storeAccountId(response.accountInfo.id)
        TokenUpdater.shared.set(validUntil: response.validUntil)
        
        if let navigationController {
            navigationController.pushViewController(HomeViewController(
                authenticationResponse: response
            ), animated: true)
        }
    }

    func receive(transactionInfo: [Service.TransactionInfo]) {
        Persistence.storeTransactions(transactionInfo)
    }
    
    func receive(userRegisterResponse response: Service.UserRegisterResponse) {
        let alert = UIAlertController(title: "Registration successful!", message: nil, preferredStyle: .alert)
        alert.addAction(.init(title: "Ok", style: .default) { _ in
            alert.dismiss(animated: true)
        })
        self.present(alert, animated: true)
    }
    func receive(error: Service.Err) {
        let alert = UIAlertController(title: "Error!", message: error.description, preferredStyle: .alert)
        alert.addAction(.init(title: "Dismiss", style: .cancel) { _ in
            alert.dismiss(animated: true)
        })
        self.present(alert, animated: true)
    }
}
