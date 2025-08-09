import UIKit

final class TrackerCreationCollectionOptionSectionHeaderView: UICollectionReusableView {
    
    static let reuseIdentifier = "TrackerCreationCollectionOptionSectionHeaderView"
    
    private lazy var titleLabel: UILabel = {
        .init()
    }()
    
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
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupView() {
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
                
        addSubview(titleLabel)
        
        NSLayoutConstraint.activate([
            titleLabel.centerYAnchor.constraint(equalTo: centerYAnchor),
            titleLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 28)
        ])
    }
}
