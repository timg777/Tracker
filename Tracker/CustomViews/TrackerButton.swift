import UIKit

final class TrackerButton: UIButton {
    enum Position {
        case bottom, bottomLeft, bottomRight
    }
    
    // MARK: - Internal Properties
    var title: String? {
        didSet {
            setAttributedTitle(
                NSAttributedString(
                    string: title ?? "",
                    attributes: [
                        .font: UIFont.systemFont(ofSize: 16, weight: .medium),
                        .foregroundColor: titleColor ?? UIColor.ypWhite
                    ]
                ),
                for: .normal
            )
        }
    }
    var titleColor: UIColor? {
        didSet {
            setAttributedTitle(
                NSAttributedString(
                    string: title ?? "",
                    attributes: [
                        .font: UIFont.systemFont(ofSize: 16, weight: .medium),
                        .foregroundColor: titleColor ?? UIColor.white
                    ]
                ),
                for: .normal
            )
        }
    }
    
    // MARK: - Internal Initizalization
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: - Extensions + Private TrackerButton Setting Up Views
private extension TrackerButton {
    func setupViews() {
        layer.cornerRadius = 16
        backgroundColor = .ypBlack
        setTitleColor(.ypWhite, for: .normal)
    }
}

// MARK: - Extensions + Internal TrackerButton Helpers
extension TrackerButton {
    func makeInactive() {
        UIView.animate(withDuration: 0.2) { [weak self] in
            guard let self else { return }
            layer.opacity = 0.4
            isEnabled = false
        }
    }
    func makeActive() {
        UIView.animate(withDuration: 0.2) { [weak self] in
            guard let self else { return }
            layer.opacity = 1
            isEnabled = true
        }
    }
    
    func activateConstraints(
        view: UIView,
        position: Position
    ) {
        NSLayoutConstraint.activate([
            heightAnchor.constraint(
                equalToConstant: ViewsHeightConstant.buttonHeight.rawValue
            ),
            bottomAnchor.constraint(
                equalTo: view.safeAreaLayoutGuide.bottomAnchor
            )
        ])
        
        switch position {
        case .bottom:
            NSLayoutConstraint.activate([
                leadingAnchor.constraint(
                    equalTo: view.leadingAnchor,
                    constant: 16
                ),
                trailingAnchor.constraint(
                    equalTo: view.trailingAnchor,
                    constant: -16
                )
            ])
        case .bottomLeft:
            NSLayoutConstraint.activate([
                leadingAnchor.constraint(
                    equalTo: view.leadingAnchor,
                    constant: 16
                ),
                trailingAnchor.constraint(
                    equalTo: view.centerXAnchor,
                    constant: -4
                )
            ])
        case .bottomRight:
            NSLayoutConstraint.activate([
                leadingAnchor.constraint(
                    equalTo: view.centerXAnchor,
                    constant: 4
                ),
                trailingAnchor.constraint(
                    equalTo: view.trailingAnchor,
                    constant: -16
                ),
            ])
        }
    }
}
