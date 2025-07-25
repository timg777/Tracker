import UIKit

final class NoContentPlaceHolderView {
    // MARK: - Private Views
    lazy var verticalStackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [imageView, label])
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .vertical
        stackView.spacing = 8
        return stackView
    }()
    private lazy var imageView: UIImageView = {
        .init()
    }()
    private lazy var label: UILabel = {
        .init()
    }()
    
    // MARK: - Internal Properties
    var title: String? {
        didSet {
            label.attributedText =
            NSAttributedString(
                string: title ?? "",
                attributes: [
                    .font: UIFont.systemFont(ofSize: 12, weight: .medium),
                    .foregroundColor: UIColor.ypBlack
                ]
            )
        }
    }
    var image: UIImage? {
        didSet {
            imageView.image = image
            imageView.contentMode = .scaleAspectFit
        }
    }
    var type: NoContentType?
}
