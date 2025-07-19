import UIKit

final class TrackerTextField: UITextField {
    // MARK: - Internal Properties
    var placeholderText: String? {
        didSet {
            attributedPlaceholder =
            NSAttributedString(
                string: placeholderText ?? "",
                attributes: [
                    .font: UIFont.systemFont(ofSize: 17, weight: .regular),
                    .foregroundColor: UIColor.ypGray
                ]
            )
        }
    }
    
    // MARK: - Initialization
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setupViews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: - Extensions + Private TrackerTextField Setting Up Views
private extension TrackerTextField {
    func setupViews() {
        leftView = UIView(
            frame: CGRect(
                x: 0,
                y: 0,
                width: 16,
                height: 1
            )
        )
        leftViewMode = .always
        clearButtonMode = .whileEditing
        backgroundColor = .background
        layer.cornerRadius = 16
        
        layer.zPosition = 1
    }
}

// MARK: - Extensions + Internal TrackerTextField Helpers
extension TrackerTextField {
    func activateConstraints(
        view: UIView
    ) {
        NSLayoutConstraint.activate([
            leadingAnchor.constraint(
                equalTo: view.leadingAnchor,
                constant: 15
            ),
            trailingAnchor.constraint(
                equalTo: view.trailingAnchor,
                constant: -16
            ),
            heightAnchor.constraint(
                equalToConstant: ViewsHeightConstant.textFieldHeight.rawValue
            ),
            topAnchor.constraint(
                equalTo: view.safeAreaLayoutGuide.topAnchor,
                constant: 24
            )
        ])
    }
}
