import UIKit

final class FilterOptionCell: TrackerTableViewCell {
    
    // MARK: - Private Views
    private lazy var titleView: UILabel = {
        .init()
    }()
    
    // MARK: - Internal Static Constraints
    static let reuseIdentifier: String = "FilterOptionCell"
    
    // MARK: - Internal Properties
    var option: FilterOption? {
        didSet {
            guard let option else { return }
            
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
                string: option.title,
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
     
        setupView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

private extension FilterOptionCell {
    func setupView() {
        backgroundColor = .background
        
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
