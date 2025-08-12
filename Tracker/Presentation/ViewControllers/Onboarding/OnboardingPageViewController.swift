import UIKit

final class OnboardingPageViewController: UIViewController {
    
    // MARK: - Private Views
    lazy var backgroundImage: UIImageView = {
        .init()
    }()
    
    lazy var titleLabel: UILabel = {
        .init()
    }()
    
    // MARK: - Private Constants
    private let currentPage: OnboardingPage
    
    // MARK: - Internal Initialization
    init(currentPage: OnboardingPage) {
        self.currentPage = currentPage
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - View Life Cycles
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupViews()
    }
    
}

// MARK: - Extensions + Private OnboardingPageViewController Views Configuring
private extension OnboardingPageViewController {
    
    var titleLabelParagraphStyle: NSMutableParagraphStyle {
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineBreakMode = .byWordWrapping
        paragraphStyle.alignment = .center
        paragraphStyle.minimumLineHeight = 32
        paragraphStyle.maximumLineHeight = 32
        return paragraphStyle
    }
    
    var titleLabelAttributes: [NSAttributedString.Key : Any] {
        [
            .font: UIFont.ypBold32,
            .foregroundColor: UIColor.ypBlack,
            .paragraphStyle: titleLabelParagraphStyle,
            .kern: 0
        ]
    }
    
    var titleLabelDeltaHeight: CGFloat {
        let text = NSString(string: titleLabel.text ?? "")
        let boundingRect = text.boundingRect(
            with: .init(
                width: view.bounds.width - 32,
                height: .greatestFiniteMagnitude
            ),
            options: [.usesLineFragmentOrigin, .usesFontLeading],
            attributes: titleLabelAttributes,
            context: nil
        )
        
        return ceil(boundingRect.height)
    }
    
    func configureTitleLabel() {
        titleLabel.attributedText =
        NSAttributedString(
            string: currentPage.title,
            attributes: titleLabelAttributes
        )
        titleLabel.numberOfLines = 2
    }
    
    func configureBackgroundImage() {
        let image = UIImage(resource: currentPage.backgroundImageReource)
        backgroundImage.image = image
        backgroundImage.backgroundColor = .clear
    }
}

// MARK: - Extensions + Private OnboardingPageViewController Views Constraints Activation
private extension OnboardingPageViewController {
    func titleLabelConstraintsActivate() {
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(titleLabel)
        
        NSLayoutConstraint.activate([
            titleLabel.leadingAnchor.constraint(
                equalTo: view.leadingAnchor,
                constant: 16
            ),
            titleLabel.trailingAnchor.constraint(
                equalTo: view.trailingAnchor,
                constant: -16
            ),
            titleLabel.centerYAnchor.constraint(
                equalTo: view.centerYAnchor,
                constant: titleLabelDeltaHeight
            )
        ])
    }
    
    func backgroundImageConstraintsActivate() {
        backgroundImage.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(backgroundImage)
        
        NSLayoutConstraint.activate([
            backgroundImage.leadingAnchor.constraint(
                equalTo: view.leadingAnchor
            ),
            backgroundImage.trailingAnchor.constraint(
                equalTo: view.trailingAnchor
            ),
            backgroundImage.topAnchor.constraint(
                equalTo: view.topAnchor
            ),
            backgroundImage.bottomAnchor.constraint(
                equalTo: view.bottomAnchor
            )
        ])
    }
}

// MARK: - Extensions + Private OnboardingPageViewController Setting Up Views
private extension OnboardingPageViewController {
    func setupViews() {
        view.backgroundColor = .clear
        
        configureTitleLabel()
        configureBackgroundImage()
        
        backgroundImageConstraintsActivate()
        titleLabelConstraintsActivate()
    }
}
