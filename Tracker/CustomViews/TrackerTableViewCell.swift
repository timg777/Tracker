import UIKit

class TrackerTableViewCell: UITableViewCell {
    // MARK: - Private Views
    private lazy var separator: UIView = {
        .init()
    }()
    
    // MARK: - Internal Properties
    var isLastItem: Bool? {
        didSet {
            separator.isHidden = isLastItem ?? true
        }
    }
    
    // MARK: - View Life Cycles
    override func didMoveToWindow() {
        super.didMoveToWindow()
        
        setupSelf()
    }
}

// MARK: - Extensions + Private TrackerTableViewCell Setting Up
private extension TrackerTableViewCell {
    func setupSelf() {
        backgroundColor = .background
        selectionStyle = .none
        
        configureSeparator()
        separatorConstraintsActivate()
    }
    
    func configureSeparator() {
        separator.backgroundColor = .ypGray.withAlphaComponent(0.5)
    }
    
    func separatorConstraintsActivate() {
        separator.translatesAutoresizingMaskIntoConstraints = false
        
        contentView.addSubview(separator)
        
        NSLayoutConstraint.activate([
            separator.leadingAnchor.constraint(
                equalTo: leadingAnchor,
                constant: 16
            ),
            separator.trailingAnchor.constraint(
                equalTo: trailingAnchor,
                constant: -16
            ),
            separator.heightAnchor.constraint(
                equalToConstant: 1
            ),
            separator.bottomAnchor.constraint(
                equalTo: contentView.bottomAnchor
            )
        ])
    }
}
