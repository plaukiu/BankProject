import UIKit

extension HomeViewController {
    var settingsViewController: UIAlertController {
        
        let view = UIAlertController(title: "Settings",
                                     message: nil,
                                     preferredStyle: .actionSheet)
        
        view.addAction(.init(title: "Change login details",
                             style: .default) { [unowned self] _ in
            
            let view = UIAlertController(title: "Change login details",
                                         message: nil,
                                         preferredStyle: .alert)
            view.addTextField { textField in
                textField.placeholder = "phone number"
                textField.keyboardType = .phonePad
            }
            view.addTextField { textField in
                textField.placeholder = "password"
                textField.keyboardType = .asciiCapable
                textField.autocorrectionType = .no
                textField.isSecureTextEntry = true
                textField.textContentType = .oneTimeCode
            }
            view.addTextField { textField in
                textField.placeholder = "confirm"
                textField.keyboardType = .asciiCapable
                textField.autocorrectionType = .no
                textField.isSecureTextEntry = true
                textField.textContentType = .oneTimeCode
            }
            
            view.addAction(.init(title: "OK", style: .default) { [unowned self] _ in
                guard let newPhoneNumber = view.textFields![0].text,
                      let newPassword = view.textFields![1].text,
                      let confirm = view.textFields![2].text,
                      !newPhoneNumber.isEmpty,
                      !newPassword.isEmpty,
                      !confirm.isEmpty
                else { return }

                ServiceWrapper
                    .updateUser(
                        currentPhoneNumber: userDetails.accountInfo.ownerPhoneNumber,
                        newPhoneNumber: newPhoneNumber,
                        newPassword: newPassword,
                        token: userDetails.accessToken,
                        receiver: self)
                    .makeRequest()
            })
            
            view.addAction(.init(title: "Cancel", style: .cancel))
            self.present(view, animated: true)
        })
        
        // apačioje kiti actionai
        
        view.addAction(.init(title: "Log Out", style: .destructive) { [unowned self] _ in
            TokenUpdater.shared.dismiss()
            navigationController?.popViewController(animated: true)
        })
        
        return view
    }
}

extension HomeViewController: UserAuthenticationResponseReceiver {
    func receive(userAuthenticationResponse: Service.UserAuthenticationResponse) {
        authenticationResponse = userAuthenticationResponse
    }
}
