import UIKit

final class TrackerCreationCollectionOptionSectionHeaderView: UICollectionReusableView {
    
    // MARK: - Internal Static Constants
    static let reuseIdentifier = "TrackerCreationCollectionOptionSectionHeaderView"
    
    // MARK: - Private Vies
    private lazy var titleLabel: UILabel = {
        .init()
    }()
    
    // MARK: - Internal Properties
    var title: String? {
        didSet {
            guard let title else { return }
            titleLabel.attributedText =
            NSAttributedString(
                string: title,
                attributes: [.font: UIFont.ypBold19]
            )
        }
    }
    
    // MARK: - Internal Initialization
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: - Extensions + TrackerCreationCollectionOptionSectionHeaderView Views Setting Up
private extension TrackerCreationCollectionOptionSectionHeaderView {
    func setupView() {
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
                
        addSubview(titleLabel)
        
        NSLayoutConstraint.activate([
            titleLabel.centerYAnchor.constraint(equalTo: centerYAnchor),
            titleLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 28)
        ])
    }
}
