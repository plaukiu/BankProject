import UIKit

struct TransactionData {
    enum UserIs {
        case sender(receiver: String)
        case receiver(sender: String)
        
        var target: String {
            switch self {
            case .sender(receiver: let receiver):
                return receiver
            case .receiver(sender: let sender):
                return sender
            }
        }
    }

    var status: UserIs = .sender(receiver: "")
    var date: Date = .init()
    var comment: String = ""
    var amount: Double = 0
    var currency: String = ""
}

class AutoTableView: UITableView {
    override func layoutSubviews() {
        super.layoutSubviews()
        self.invalidateIntrinsicContentSize()
    }
    override var intrinsicContentSize: CGSize {
        get {
            var height:CGFloat = 0;
            for s in 0..<self.numberOfSections {
                let nRowsSection = self.numberOfRows(inSection: s)
                for r in 0..<nRowsSection {
                    height += self.rectForRow(at: IndexPath(row: r, section: s)).size.height;
                }
            }
            return CGSize(width: UIView.noIntrinsicMetric, height: height)
        }
    }
}

extension TransactionCell {
    static let identifier = "TransactionCell"
}

class TransactionCell: UITableViewCell {
    
    var transactionStack: UIStackView = .init()
    var comment: UILabel = .init()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setup(data: TransactionData) {
        transactionStack = {
            let date: UILabel = UILabel(frame: .zero)
            date.text = data.date.formatted(
                .dateTime
                    .year(.twoDigits).month(.narrow).day()
                    .hour(.defaultDigits(amPM: .omitted)).minute()
            )
            let targetPhoneNumberLabel: UILabel = UILabel(frame: .zero)
            targetPhoneNumberLabel.text = {
                switch data.status {
                case .sender(receiver: let receiver):
                    return "to \(receiver)"
                case .receiver(sender: let sender):
                    return "from \(sender)"
                }
            }()
            let amountAndCurrency: UILabel = UILabel(frame: .zero)
            amountAndCurrency.text = "\(data.amount) \(data.currency)"
            
            date.font = .systemFont(ofSize: 12)
            targetPhoneNumberLabel.font = .systemFont(ofSize: 12)
            amountAndCurrency.font = .systemFont(ofSize: 12)

            let view = UIStackView(arrangedSubviews: [
                date, targetPhoneNumberLabel, amountAndCurrency
            ])
            view.axis = .horizontal
            view.distribution = .fillProportionally
            view.alignment = .leading
            
            return view
        }()
        comment.text = data.comment
        comment.font = .systemFont(ofSize: 10)
        updateLayout(status: data.status)
    }

    func updateLayout(status: TransactionData.UserIs) {
        transactionStack.translatesAutoresizingMaskIntoConstraints = false
        comment.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(transactionStack)
        contentView.addSubview(comment)

        switch status {
        case .sender(_):
            backgroundColor = .systemRed
        case .receiver(_):
            backgroundColor = .systemGreen
        }
        
        NSLayoutConstraint.activate([
            transactionStack.leadingAnchor.constraint(equalTo: contentView.layoutMarginsGuide.leadingAnchor),
            transactionStack.trailingAnchor.constraint(equalTo: contentView.layoutMarginsGuide.trailingAnchor),
            transactionStack.topAnchor.constraint(equalTo: contentView.layoutMarginsGuide.topAnchor),
            
            comment.leadingAnchor.constraint(equalTo: contentView.layoutMarginsGuide.leadingAnchor),
            comment.trailingAnchor.constraint(equalTo: contentView.layoutMarginsGuide.trailingAnchor),
            comment.topAnchor.constraint(equalTo: transactionStack.bottomAnchor),
            comment.bottomAnchor.constraint(equalTo: contentView.layoutMarginsGuide.bottomAnchor),
        ])
        
        
        layoutIfNeeded()
    }
    override func prepareForReuse() {
        transactionStack.subviews.forEach {
            ($0 as! UILabel).text = nil
        }
        comment.text = nil
    }
}
