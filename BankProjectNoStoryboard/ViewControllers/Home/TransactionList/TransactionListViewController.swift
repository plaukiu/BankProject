import UIKit
import CoreData

extension Persistence {
    enum Filter {
        case all
        case incoming
        case outgoing
        case comment(String)
        case phoneNumber(String)
        case amount(from: Double, to: Double)
        case date(from: Double, to: Double)
        
        var predicate: NSPredicate {
            let format = "%K == %@"
            switch self {
            case .all:
                return .init()
            case .incoming:
                let id = Persistence.fetchAccountId().first!.id
                return .init(format: format, argumentArray: ["receivingAccountId", String(id)])
            case .outgoing:
                let id = Persistence.fetchAccountId().first!.id
                return .init(format: format, argumentArray: ["sendingAccountId", String(id)])
            case .comment(let comment):
                return .init(format: format, argumentArray: ["comment", comment])
            case .phoneNumber(let number):
                return .init(format: format, argumentArray: ["receiverPhoneNumber", number])
            case .amount(from: let from, to: let to):
                let format = "%K >= %@ AND %K <= %@"
                return .init(format: format, argumentArray: ["amount", from, "amount", to])
            case .date(from: let from, to: let to):
                let format = "%K >= %@ AND %K <= %@"
                return .init(format: format, argumentArray: ["transactionTime", from, "transactionTime", to])
            }
        }
    }
    
    static func fetch(filtered: Filter) -> [TransactionInfo] {
        let request: NSFetchRequest<TransactionInfo> = TransactionInfo.fetchRequest()
        if case .all = filtered {
        } else {
            request.predicate = filtered.predicate
        }
        do {
            return try context.fetch(request)
        } catch {
            fatalError()
        }
    }
}


class TransactionListViewController: UIViewController {
    typealias UserAuthenticationResponse = Service.UserAuthenticationResponse
    
    var transactions: [TransactionInfo] = [] {
        didSet {
            sortTransactions()
        }
    }
    var filter: Persistence.Filter = .all {
        didSet {
            reload()
            transactions = Persistence.fetch(filtered: filter)
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
    }
    let userDetails: UserAuthenticationResponse
    
    lazy var filterStack: UIStackView = {
        
        let all = UIButton(primaryAction: .init { _ in self.filter = .all } )
        all.setImage(.init(systemName: "circle"), for: .normal)
        
        let incoming = UIButton(primaryAction: .init { _ in self.filter = .incoming } )
        incoming.setImage(.init(systemName: "arrow.down.circle"), for: .normal)
        
        let outgoing = UIButton(primaryAction: .init { _ in self.filter = .outgoing } )
        outgoing.setImage(.init(systemName: "arrow.up.circle"), for: .normal)
        
        // MARK: TextInputFilters
        let popup = UIButton(primaryAction: .init { _ in
            let controller = UIAlertController(title: "Select filter", message: nil, preferredStyle: .actionSheet)
            
            controller.addAction(.init(title: "Comment", style: .default) { _ in
                let popup = UIAlertController(title: "Filter by comment", message: nil, preferredStyle: .alert)
                popup.addTextField { textField in
                    textField.placeholder = "comment"
                }
                popup.addAction(.init(title: "Go", style: .default) { _ in
                    guard let text = popup.textFields![0].text else { return }
                    self.filter = .comment(text)
                })
                self.present(popup, animated: false)
            })
            controller.addAction(.init(title: "Phone Number", style: .default) { _ in
                let popup = UIAlertController(title: "Filter by phoneNumber", message: nil, preferredStyle: .alert)
                popup.addTextField { textField in
                    textField.placeholder = "Phone number"
                    textField.keyboardType = .phonePad
                }
                popup.addAction(.init(title: "Go", style: .default) { _ in
                    guard let text = popup.textFields![0].text else { return }
                    self.filter = .phoneNumber(text)
                })
                self.present(popup, animated: false)
            })
            controller.addAction(.init(title: "Amount", style: .default) { _ in
                let popup = UIAlertController(title: "Filter by amount", message: nil, preferredStyle: .alert)
                popup.addTextField { textField in
                    textField.placeholder = "minimum"
                    textField.keyboardType = .decimalPad
                }
                popup.addTextField { textField in
                    textField.placeholder = "maximum"
                    textField.keyboardType = .decimalPad
                }
                popup.addAction(.init(title: "Go", style: .default) { _ in
                    guard let text1 = popup.textFields![0].text,
                          let text2 = popup.textFields![1].text,
                          let num1 = Double(text1),
                          let num2 = Double(text2)
                    else { return }
                    self.filter = .amount(from: num1, to: num2)
                })
                self.present(popup, animated: false)
            })
            controller.addAction(.init(title: "Date", style: .default) { _ in
                let popup = UIAlertController(title: "Filter by amount", message: nil, preferredStyle: .alert)
                popup.addTextField { textField in
                    textField.placeholder = "minimum"
                    textField.keyboardType = .decimalPad
                }
                popup.addTextField { textField in
                    textField.placeholder = "maximum"
                    textField.keyboardType = .decimalPad
                }
                popup.addAction(.init(title: "Go", style: .default) { _ in
                    guard let text1 = popup.textFields![0].text,
                          let text2 = popup.textFields![1].text,
                          let num1 = Double(text1),
                          let num2 = Double(text2)
                    else { return }
                    self.filter = .date(from: num1, to: num2)
                })
                self.present(popup, animated: false)
            })
            controller.addAction(.init(title: "Cancel", style: .cancel) { _ in
                controller.dismiss(animated: true)
            })
            self.present(controller, animated: true)
        })
        
        popup.setImage(.init(systemName: "pencil.circle"), for: .normal)
        let view = UIStackView(arrangedSubviews: [
            all, incoming, outgoing, popup
        ])
        view.translatesAutoresizingMaskIntoConstraints = false
        view.axis = .horizontal
        view.distribution = .fillEqually
        view.alignment = .center
        return view
    }()

    lazy var tableView: UITableView = {
        let view = UITableView(frame: .zero, style: .plain)
        view.register(TransactionCell.self,
                           forCellReuseIdentifier: TransactionCell.identifier)
        view.delegate = self
        view.dataSource = self
        return view
    }()
    
    // MARK: - Init
    
    init(userDetails: UserAuthenticationResponse) {
        self.transactions = Persistence.fetchTransactions()
        self.userDetails = userDetails
        super.init(nibName: nil, bundle: nil)
        sortTransactions()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.addSubview(filterStack)
        view.addSubview(tableView)
        view.backgroundColor = .systemGray
        updateLayout()
    }
    func updateLayout() {
        tableView.translatesAutoresizingMaskIntoConstraints = false
        let margins = view.layoutMarginsGuide
        NSLayoutConstraint.activate([
            filterStack.topAnchor.constraint(equalTo: margins.topAnchor),
            filterStack.leadingAnchor.constraint(equalTo: margins.leadingAnchor),
            filterStack.trailingAnchor.constraint(equalTo: margins.trailingAnchor),
            filterStack.heightAnchor.constraint(equalToConstant: 34),
            
            tableView.topAnchor.constraint(equalTo: filterStack.bottomAnchor),
            tableView.bottomAnchor.constraint(equalTo: margins.bottomAnchor),
            tableView.leadingAnchor.constraint(equalTo: margins.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: margins.trailingAnchor)
        ])
    }
    private func reload() {
        transactions = []
        tableView.reloadData()
    }
    private func sortTransactions() {
        transactions.sort { previous, next in
            previous.transactionTime > next.transactionTime
        }
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
