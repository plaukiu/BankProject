import UIKit
import CoreData

class LoginViewController: UIViewController, UITextFieldDelegate {
    
    enum State { case login, register }
    var state = State.login {
        didSet {
            updateLayout()
        }
    }
    
    // MARK: - Views
    
    lazy var actionButton: UIButton = {
        let view = UIButton(type: .roundedRect)
        view.translatesAutoresizingMaskIntoConstraints = false
        view.addAction(UIAction { [unowned self] _ in
            self.submit()
        }, for: .touchUpInside)
        return view
    }()
    
    lazy var segmentedControl: UISegmentedControl = {
        let view = UISegmentedControl()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.insertSegment(withTitle: "login", at: 0, animated: true)
        view.insertSegment(withTitle: "register", at: 1, animated: true)
        view.addAction(UIAction { [unowned self] _ in
            self.state = view.selectedSegmentIndex == 0 ? .login : .register
        }, for: .valueChanged)
        view.selectedSegmentIndex = 0
        return view
    }()

    lazy var bankLabel: UILabel = {
        let view = UILabel()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.text = "bank."
        return view
    }()
    
    // MARK: Fields
    
    lazy var phoneNumberField: UITextField = {
        let view = UITextField(frame: .zero)
        view.translatesAutoresizingMaskIntoConstraints = false
        view.placeholder = "phone number..."
        view.borderStyle = .roundedRect
        view.keyboardType = .phonePad
        
        view.delegate = self
        return view
    }()
    lazy var passwordField: UITextField = {
        let view = UITextField(frame: .zero)
        view.translatesAutoresizingMaskIntoConstraints = false
        view.placeholder = "password..."
        view.borderStyle = .roundedRect
        view.keyboardType = .asciiCapable
        
        view.isSecureTextEntry = true
        view.autocapitalizationType = .none
        view.autocorrectionType = .no
        view.textContentType = .oneTimeCode
        
        view.delegate = self
        return view
    }()
    lazy var confirmField: UITextField = {
        let view = UITextField(frame: .zero)
        view.translatesAutoresizingMaskIntoConstraints = false
        view.placeholder = "confirm..."
        view.borderStyle = .roundedRect
        view.keyboardType = .asciiCapable
        
        view.isSecureTextEntry = true
        view.autocorrectionType = .no
        view.textContentType = .oneTimeCode
        view.autocapitalizationType = .none
        
        view.delegate = self
        return view
    }()
    lazy var currencyField: UITextField = {
        let view = UITextField(frame: .zero)
        view.translatesAutoresizingMaskIntoConstraints = false
        view.placeholder = "currency..."
        view.borderStyle = .roundedRect
        
        view.keyboardType = .asciiCapable
        view.autocorrectionType = .no
        view.autocapitalizationType = .allCharacters
        
        view.delegate = self
        return view
    }()
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if textField === phoneNumberField {
            let allowed: CharacterSet = .decimalDigits.inverted
            let filtered = string
                .components(separatedBy: allowed)
                .joined(separator: "")
            return string == filtered
        } else {
            return true
        }
    }
    
    override func viewDidLoad() {
        view.backgroundColor = .white
        view.addSubview(bankLabel)
        view.addSubview(phoneNumberField)
        view.addSubview(passwordField)
        view.addSubview(confirmField)
        view.addSubview(currencyField)
        view.addSubview(actionButton)
        view.addSubview(segmentedControl)
        updateLayout()
    }
    
    // MARK: - Layout
    
    let spacing: CGFloat = 10
    let fieldHeight: CGFloat = 34
    var margins: UILayoutGuide { view.layoutMarginsGuide }
    
    func updateLayout() {
        switch state {
        case .login:
            
            UIView.animate(withDuration: 0.15, delay: 0, options: .transitionCrossDissolve) { [unowned self] in
                self.actionButton.setTitle("enter", for: .normal)
                confirmField.isHidden = true
                currencyField.isHidden = true
                NSLayoutConstraint.deactivate(self.registerConstraints)
                NSLayoutConstraint.activate(self.loginConstraints)
                view.layoutIfNeeded()
            }

        case .register:
            
            UIView.animate(withDuration: 0.15, delay: 0, options: .transitionCrossDissolve) { [unowned self] in
                self.actionButton.setTitle("register", for: .normal)
                confirmField.isHidden = false
                currencyField.isHidden = false
                NSLayoutConstraint.deactivate(self.loginConstraints)
                NSLayoutConstraint.activate(self.registerConstraints)
                view.layoutIfNeeded()
            }
        }
    }
    
    lazy var commonConstraints: [NSLayoutConstraint] = [
            // height
            phoneNumberField.heightAnchor.constraint(equalToConstant: fieldHeight),
            passwordField.heightAnchor.constraint(equalToConstant: fieldHeight),
            confirmField.heightAnchor.constraint(equalToConstant: fieldHeight),
            currencyField.heightAnchor.constraint(equalToConstant: fieldHeight),
            segmentedControl.heightAnchor.constraint(equalToConstant: fieldHeight),
            
            // vertical
            bankLabel.topAnchor.constraint(equalTo: margins.topAnchor, constant: 150),
            bankLabel.leadingAnchor.constraint(equalTo: margins.leadingAnchor, constant: 55),

            
            phoneNumberField.topAnchor.constraint(equalTo: bankLabel.bottomAnchor, constant: 120),

            passwordField.topAnchor.constraint(equalTo: phoneNumberField.bottomAnchor, constant: spacing),
            confirmField.topAnchor.constraint(equalTo: phoneNumberField.bottomAnchor, constant: spacing),
            
            currencyField.topAnchor.constraint(equalTo: passwordField.bottomAnchor, constant: spacing),
            segmentedControl.topAnchor.constraint(equalTo: passwordField.bottomAnchor, constant: spacing),
            
            actionButton.topAnchor.constraint(equalTo: currencyField.bottomAnchor, constant: 30),
            
            // horizontal
            phoneNumberField.leadingAnchor.constraint(equalTo: margins.leadingAnchor, constant: 55),
            passwordField.leadingAnchor.constraint(equalTo: margins.leadingAnchor, constant: 55),
            segmentedControl.leadingAnchor.constraint(equalTo: margins.leadingAnchor, constant: 55),
            
            phoneNumberField.trailingAnchor.constraint(equalTo: margins.trailingAnchor, constant: -55),
            segmentedControl.trailingAnchor.constraint(equalTo: margins.centerXAnchor, constant: -5),
            actionButton.trailingAnchor.constraint(equalTo: margins.trailingAnchor, constant: -55),
        ]
    
    lazy var loginConstraints: [NSLayoutConstraint] = commonConstraints + [
            passwordField.trailingAnchor.constraint(equalTo: margins.trailingAnchor, constant: -55),
            
            confirmField.leadingAnchor.constraint(equalTo: margins.trailingAnchor, constant: -55),
            confirmField.trailingAnchor.constraint(equalTo: margins.trailingAnchor, constant: -55),
            currencyField.leadingAnchor.constraint(equalTo: margins.trailingAnchor, constant: -55),
            currencyField.trailingAnchor.constraint(equalTo: margins.trailingAnchor, constant: -55),
        ]

    lazy var registerConstraints: [NSLayoutConstraint] = commonConstraints + [
            passwordField.trailingAnchor.constraint(equalTo: margins.centerXAnchor, constant: -5),
            
            confirmField.leadingAnchor.constraint(equalTo: passwordField.trailingAnchor, constant: spacing),
            currencyField.leadingAnchor.constraint(equalTo: margins.centerXAnchor, constant: 5),
            confirmField.trailingAnchor.constraint(equalTo: margins.trailingAnchor, constant: -55),
            currencyField.trailingAnchor.constraint(equalTo: margins.trailingAnchor, constant: -55),
        ]
}
