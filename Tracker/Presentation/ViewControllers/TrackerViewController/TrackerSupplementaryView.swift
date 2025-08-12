import UIKit

final class TrackerSupplementaryView: UICollectionReusableView {
    
    // MARK: - Internal Static Constants
    static let reuseHeaderIdentifier = "TrackerSupplementaryHeaderView"
    
    // MARK: - Private Views
    private lazy var titleLabel: UILabel = {
        .init()
    }()
    
    // MARK: - Internal Properties
    var title: String? {
        didSet {
            let paragraphStyle = NSMutableParagraphStyle()
            paragraphStyle.lineBreakMode = .byWordWrapping
            paragraphStyle.alignment = .left
            paragraphStyle.minimumLineHeight = 19
            paragraphStyle.maximumLineHeight = 19
            
            let fontDescriptor = UIFont.ypBold19.fontDescriptor.withDesign(.rounded)
            
            titleLabel.attributedText =
            NSAttributedString(
                string: title ?? "No title",
                attributes: [
                    .font: UIFont(descriptor: fontDescriptor ?? .preferredFontDescriptor(withTextStyle: .headline), size: 19),
                    .foregroundColor: UIColor.ypBlack,
                    .paragraphStyle: paragraphStyle
                ]
            )
            titleLabel.numberOfLines = 2
        }
    }
    
    // MARK: - Internal Initialization
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setupLabel()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: - Extensions + Private TrackerSupplementaryView Setting Up Views
private extension TrackerSupplementaryView {
    func setupLabel() {
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        
        addSubview(titleLabel)
        
        NSLayoutConstraint.activate([
            titleLabel.bottomAnchor.constraint(
                equalTo: bottomAnchor
            ),
            titleLabel.leadingAnchor.constraint(
                equalTo: leadingAnchor,
                constant: 12
            ),
            titleLabel.trailingAnchor.constraint(
                equalTo: trailingAnchor,
                constant: -12
            )
        ])
    }
}
