import UIKit

final class CategoryOptionsCell: UITableViewCell {
    
    // MARK: - Private Views
    private lazy var titleView: UILabel = {
        .init()
    }()
    
    // MARK: - Internal Static Constraints
    static let reuseIdentifier: String = "NewHabitCreationCategoryOptionsCell"
    
    // MARK: - Internal Properties
    var title: String? {
        didSet {
            let paragraphStyle: NSMutableParagraphStyle = {
                let paragraphStyle: NSMutableParagraphStyle = .init()
                paragraphStyle.lineBreakMode = .byWordWrapping
                paragraphStyle.alignment = .left
                paragraphStyle.minimumLineHeight = 20
                paragraphStyle.maximumLineHeight = 20
                return paragraphStyle
            }()
            
            titleView.attributedText =
            NSAttributedString(
                string: title ?? "",
                attributes: [
                    .font: UIFont.ypRegular17,
                    .foregroundColor: UIColor.ypBlack,
                    .paragraphStyle: paragraphStyle
                ]
            )
            
            titleView.numberOfLines = 2
        }
    }
    
    // MARK: - Internal Initialization
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

// MARK: - Extensions + Private CategoryOptionsCell Setting Up Views
private extension CategoryOptionsCell {
    func setUpViews() {
        backgroundColor = .background
        
        titleViewConstraintsActivate()
    }
}

// MARK: - Extensions + CategoryOptionsCell Constraints Activation
private extension CategoryOptionsCell {
    func titleViewConstraintsActivate() {
        titleView.translatesAutoresizingMaskIntoConstraints = false
        
        contentView.addSubview(titleView)
        
        NSLayoutConstraint.activate([
            titleView.leadingAnchor.constraint(
                equalTo: contentView.leadingAnchor,
                constant: 16
            ),
            titleView.trailingAnchor.constraint(
                equalTo: contentView.trailingAnchor,
                constant: -16
            ),
            titleView.centerYAnchor.constraint(
                equalTo: contentView.centerYAnchor
            )
        ])
    }
}
