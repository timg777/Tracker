import UIKit

final class DisclosureOptionTableCell: UITableViewCell {
    
    // MARK: - Static Constants
    static let reuseIdentifier = "OptionTableCellForDisclosureIndicator"
    
    // MARK: - Private Views
    private lazy var titleLabel: UILabel = {
        .init()
    }()
    private lazy var selectedOptionsLabel: UILabel = {
        .init()
    }()
    private lazy var separator: UIView = {
        .init()
    }()
    
    // MARK: - Private Properties
    private var titleLabelCenterYConstraint: NSLayoutConstraint?
    
    // MARK: - Internal Properties
    var screenItem: TrackerCreationOptionScreenItem? {
        didSet {
            titleLabel.text = screenItem?.name.title
        }
    }
    var isLastItem: Bool? {
        didSet {
            separator.isHidden = isLastItem ?? true
        }
    }
    var selectedOptions: String? {
        didSet {
            let paragraphStyle: NSMutableParagraphStyle = {
                let paragraphStyle = NSMutableParagraphStyle()
                paragraphStyle.lineBreakMode = .byTruncatingTail
                return paragraphStyle
            }()
            
            selectedOptionsLabel.attributedText =
            NSAttributedString(
                string: selectedOptions ?? "",
                attributes: [
                    .font: UIFont.ypRegular17,
                    .foregroundColor: UIColor.ypGray.withAlphaComponent(0.7),
                    .paragraphStyle: paragraphStyle
                ]
            )
            
            selectedOptionsLabel.numberOfLines = 1
            
            guard let selectedOptions else { return }
            
            if selectedOptions.isEmpty {
                titleLabelCenterYConstraint?.constant = bounds.midY - titleLabel.frame.height / 2
            } else {
                titleLabelCenterYConstraint?.constant = contentView.bounds.height / 3 - titleLabel.frame.height / 2
            }
        }
    }
    
    // MARK: - Internal Initiailization
    override init(
        style: UITableViewCell.CellStyle,
        reuseIdentifier: String?
    ) {
        super.init(
            style: style,
            reuseIdentifier: reuseIdentifier
        )
        
        setUpViews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: - Extensions + Private DisclosureOptionTableCell Setting Up Views
private extension DisclosureOptionTableCell {
    func setUpViews() {
        configureCell()
        
        configureTitleLabel()
        configureSeparator()
        
        titleLabelConstraintsActivate()
        selectedOptionsLabelConstraintsActivate()
        separatorConstraintsActivate()
        
        if selectedOptions?.isEmpty ?? true {
            titleLabelCenterYConstraint?.constant = bounds.midY - titleLabel.frame.height / 2
        } else {
            titleLabelCenterYConstraint?.constant = contentView.bounds.height / 3 - titleLabel.frame.height / 2
        }
    }
}

// MARK: - Extensions + Private DisclosureOptionTableCell Views Configuring
private extension DisclosureOptionTableCell {
    func configureSeparator() {
        separator.backgroundColor = .ypGray.withAlphaComponent(0.5)
    }
    
    func configureCell() {
        backgroundColor = .background
    }
    
    func configureTitleLabel() {
        titleLabel.attributedText =
        NSAttributedString(
            string: "",
            attributes: [
                .font: UIFont.ypRegular17,
                .foregroundColor: UIColor.ypBlack
            ]
        )
    }
}

// MARK: - Extensions + Private DisclosureOptionTableCell Constraints Activation
private extension DisclosureOptionTableCell {
    func separatorConstraintsActivate() {
        separator.translatesAutoresizingMaskIntoConstraints = false
        
        contentView.addSubview(separator)
        
        NSLayoutConstraint.activate([
            separator.leadingAnchor.constraint(
                equalTo: contentView.leadingAnchor,
                constant: 16
            ),
            separator.trailingAnchor.constraint(
                equalTo: contentView.trailingAnchor,
                constant: 16
            ),
            separator.heightAnchor.constraint(
                equalToConstant: 1
            ),
            separator.bottomAnchor.constraint(
                equalTo: contentView.bottomAnchor
            )
        ])
    }
    
    func titleLabelConstraintsActivate() {
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        
        addSubview(titleLabel)
        
        titleLabelCenterYConstraint = titleLabel.topAnchor.constraint(equalTo: topAnchor, constant: bounds.midY + titleLabel.font.pointSize / 4)
        
        NSLayoutConstraint.activate([
            titleLabelCenterYConstraint ?? titleLabel.topAnchor.constraint(
                equalTo: topAnchor,
                constant: bounds.midY + titleLabel.font.pointSize / 4
            ),
            titleLabel.leadingAnchor.constraint(
                equalTo: leadingAnchor,
                constant: 16
            )
        ])
    }
    
    func selectedOptionsLabelConstraintsActivate() {
        selectedOptionsLabel.translatesAutoresizingMaskIntoConstraints = false
        
        contentView.addSubview(selectedOptionsLabel)
        
        NSLayoutConstraint.activate([
            selectedOptionsLabel.leadingAnchor.constraint(
                equalTo: contentView.leadingAnchor,
                constant: 16
            ),
            selectedOptionsLabel.trailingAnchor.constraint(
                equalTo: contentView.trailingAnchor,
                constant: -16
            ),
            selectedOptionsLabel.bottomAnchor.constraint(
                equalTo: contentView.bottomAnchor,
                constant: bounds.height / -3
            )
        ])
    }
}
