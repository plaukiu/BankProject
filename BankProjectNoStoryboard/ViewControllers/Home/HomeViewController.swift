import UIKit

class HomeViewController: UIViewController {
    typealias UserAuthenticationResponse = Service.UserAuthenticationResponse
    
    var authenticationResponse: UserAuthenticationResponse
    var userDetails: UserAuthenticationResponse { authenticationResponse }
    
    var transactions: [TransactionInfo] = [] {
        didSet {
            DispatchQueue.main.async { [unowned self] in
                transactionTableView.reloadData()
            }
        }
    }
    
    // MARK: init
    init(authenticationResponse response: UserAuthenticationResponse) {
        self.authenticationResponse = response
        super.init(nibName: nil, bundle: nil)
        
        ServiceWrapper
            .getTransactions(accountId: response.accountInfo.id, receiver: self)
            .makeRequest()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    
    
    
    
    
    
    // MARK: - Views
    
    //MARK: Balance
    lazy var balanceLabel: UILabel = {
        let view = UILabel()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.text = String(userDetails.accountInfo.balance) + userDetails.accountInfo.currency
        return view
    }()
    func redrawBalanceLabel() {
        balanceLabel.text = String(userDetails.accountInfo.balance) + userDetails.accountInfo.currency
    }
    
    //MARK: ActionStack
    lazy var actionStack: UIStackView = {
        var addMoneyButton: UIButton = {
            let view = presentingButton(targetVC: addMoneyViewController)
            view.setImage(.init(systemName: "plus.circle"), for: .normal)
            return view
        }()
        var sendMoneyButton: UIButton = {
            let view = presentingButton(targetVC: makeTransactionViewController)
            view.setImage(.init(systemName: "paperplane.circle"), for: .normal)
            // "arrow.up.forward.circle"
            return view
        }()
        var settingsButton: UIButton = {
            let view = presentingButton(targetVC: settingsViewController)
            view.setImage(.init(systemName: "gearshape.circle"), for: .normal)
            return view
        }()
        let view = UIStackView(arrangedSubviews: [
            addMoneyButton,
            sendMoneyButton,
            settingsButton
        ])
        view.translatesAutoresizingMaskIntoConstraints = false
        view.axis = .horizontal
        view.distribution = .fillEqually
        view.alignment = .center
        
        return view
    }()
    
    //MARK: TransactionTable
    lazy var transactionTableView: AutoTableView = {
        let view = AutoTableView(frame: .zero, style: .plain)
        view.translatesAutoresizingMaskIntoConstraints = false
        view.register(TransactionCell.self, forCellReuseIdentifier: TransactionCell.identifier)
        view.dataSource = self
        view.delegate = self
        view.isScrollEnabled = false
        return view
    }()
    
    // MARK: SeeAllButton
    lazy var seeAllButton: UIButton = {
        let view = UIButton(type: .roundedRect)
        view.translatesAutoresizingMaskIntoConstraints = false
        view.addAction(UIAction { [unowned self] _ in
        
            if !transactions.isEmpty {
                navigationController!.pushViewController(
                    TransactionListViewController(userDetails: userDetails),
                    animated: true)
            }
    
        }, for: .touchUpInside)
        view.setTitle("See all transactions", for: .normal)
        return view
    }()
    
    // MARK: ViewDidLoad
    override func viewDidLoad() {
        navigationController?.navigationBar.isHidden = true
        navigationController?.delegate = self
        view.backgroundColor = .white
        view.addSubview(balanceLabel)
        view.addSubview(actionStack)
        view.addSubview(transactionTableView)
        view.addSubview(seeAllButton)
        updateLayout()
    }
    
    
    
    
    
    
    
    
    
    
    // MARK: - Layout
    
    let spacing: CGFloat = 10
    let fieldHeight: CGFloat = 34
    var margins: UILayoutGuide { view.layoutMarginsGuide }

    lazy var commonConstraints: [NSLayoutConstraint] = [
        balanceLabel.topAnchor.constraint(equalTo: margins.topAnchor, constant: 150),
        balanceLabel.centerXAnchor.constraint(equalTo: margins.centerXAnchor),
//        balanceLabel.trailingAnchor.constraint(equalTo: margins.trailingAnchor, constant: -55),
        
        actionStack.topAnchor.constraint(equalTo: balanceLabel.bottomAnchor, constant: spacing),
        actionStack.heightAnchor.constraint(equalToConstant: 60),
        actionStack.leadingAnchor.constraint(equalTo: margins.leadingAnchor, constant: 55),
        actionStack.trailingAnchor.constraint(equalTo: margins.trailingAnchor, constant: -55),
        
//        transactionTableView.topAnchor.constraint(equalTo: margins.centerYAnchor),
        transactionTableView.bottomAnchor.constraint(equalTo: seeAllButton.topAnchor),
        transactionTableView.leadingAnchor.constraint(equalTo: margins.leadingAnchor),
        transactionTableView.trailingAnchor.constraint(equalTo: margins.trailingAnchor),
        
        seeAllButton.bottomAnchor.constraint(equalTo: margins.bottomAnchor),
        seeAllButton.leadingAnchor.constraint(equalTo: margins.leadingAnchor),
        seeAllButton.trailingAnchor.constraint(equalTo: margins.trailingAnchor)
    ]
    
    func updateLayout() {
        NSLayoutConstraint.activate(commonConstraints)
    }
}



// MARK: - Extensions

extension HomeViewController: UINavigationControllerDelegate {
    func navigationController(_ navigationController: UINavigationController, willShow viewController: UIViewController, animated: Bool) {
        if viewController === self {
            navigationController.navigationBar.isHidden = true
        }
        else if viewController is TransactionListViewController {
            navigationController.navigationBar.isHidden = false
        }
    }
}

extension HomeViewController: TransactionInfoReceiver {
    func receive(transactionInfo: [Service.TransactionInfo]) {
        self.transactions = Persistence.storeTransactions(transactionInfo)
    }
    
    func receive(error: Service.Err) {
        let alert = UIAlertController(title: "Error!", message: error.description, preferredStyle: .alert)
        alert.addAction(.init(title: "Dismiss", style: .cancel) { _ in
            alert.dismiss(animated: true)
        })
        self.present(alert, animated: true)
    }
}

extension HomeViewController {
    
    // MARK: PresentingButton
    // will create a button that presents another view on tap
    private func presentingButton(targetVC: UIViewController) -> UIButton {
        let view = UIButton(type: .roundedRect)
        view.translatesAutoresizingMaskIntoConstraints = false
        view.addAction(UIAction { [unowned self] _ in
            present(targetVC, animated: true)
        }, for: .touchUpInside)
        return view
    }
}
