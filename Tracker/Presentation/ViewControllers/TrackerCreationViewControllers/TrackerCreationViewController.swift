import UIKit

final class TrackerCreationViewController: UIViewController {
    
    // MARK: - Private Views
    private lazy var titleLabel: UILabel = {
        .init()
    }()
    private lazy var verticalStackView: UIStackView = {
        let view = UIStackView(arrangedSubviews: [habitButton, irregularEventButton])
        view.axis = .vertical
        view.alignment = .center
        view.spacing = 16
        return view
    }()
    private lazy var habitButton: TrackerButton = {
        .init()
    }()
    private lazy var irregularEventButton: TrackerButton = {
        .init()
    }()
    
    // MARK: - View Life Cycles
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setUpViews()
    }
    
    private func localizedTitle(for uiElement: LocalizationManager.UIElement.TrackerCreation) -> String {
        LocalizationManager.shared.localizedString(using: uiElement.rawValue)
    }
}

// MARK: - Extensions + Private TrackerCreationViewController Buttons Actions Handlers
private extension TrackerCreationViewController {
    @objc func didTapHabitButton() {
        routeToTrackerCreationOptions(isIrregularEvent: false)
    }
    @objc func didTapIrregularEventButton() {
        routeToTrackerCreationOptions(isIrregularEvent: true)
    }
    
    func routeToTrackerCreationOptions(isIrregularEvent: Bool) {
        let viewController = TrackerCreationOptionsViewController(isForEdit: false)
        viewController.navigationItem.hidesBackButton = true
        viewController.isIrregularEvent = isIrregularEvent
        navigationController?.pushViewController(viewController, animated: true)
    }
}

// MARK: - Extensions + Private TrackerCreationViewController Setting Up Views
private extension TrackerCreationViewController {
    func setUpViews() {
        configureTitleLabel()
        configureView()
        configureButtons()
        configureNavigationBar()
        
        habitButtonConstraintsActivate()
        irregularEventButtonConstraintsActivate()
        verticalStackViewConstraintsActivate()
    }
}

// MARK: - Extensions + Private TrackerCreationViewController Views Configuring
private extension TrackerCreationViewController {
    func configureView() {
        view.backgroundColor = .ypWhite
    }
    
    func configureTitleLabel() {
        titleLabel.attributedText =
        NSAttributedString(
            string: localizedTitle(for: .navigationTitle),
            attributes: [
                .font: UIFont.ypMedium16,
                .foregroundColor: UIColor.ypBlack
            ]
        )
    }
    
    func configureNavigationBar() {
        navigationItem.titleView = titleLabel
    }
    
    func configureButtons() {
        habitButton.title = localizedTitle(for: .habitButton)
        habitButton.addTarget(
            self,
            action: #selector(didTapHabitButton),
            for: .touchUpInside
        )
        
        irregularEventButton.title = localizedTitle(for: .irregularButton)
        irregularEventButton.addTarget(
            self,
            action: #selector(didTapIrregularEventButton),
            for: .touchUpInside
        )
    }
}

// MARK: - Extensions + Private TrackerCreationViewController Views Constraints Activation
private extension TrackerCreationViewController {
    func verticalStackViewConstraintsActivate() {
        verticalStackView.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(verticalStackView)
        
        NSLayoutConstraint.activate([
            verticalStackView.centerXAnchor.constraint(
                equalTo: view.centerXAnchor
            ),
            verticalStackView.centerYAnchor.constraint(
                equalTo: view.centerYAnchor
            ),
            verticalStackView.leadingAnchor.constraint(
                equalTo: view.leadingAnchor
            ),
            verticalStackView.trailingAnchor.constraint(
                equalTo: view.trailingAnchor
            )
        ])
    }
    
    func habitButtonConstraintsActivate() {
        habitButton.translatesAutoresizingMaskIntoConstraints = false
 
        NSLayoutConstraint.activate([
            habitButton.heightAnchor.constraint(
                equalToConstant: 60
            ),
            habitButton.leadingAnchor.constraint(
                equalTo: verticalStackView.leadingAnchor,
                constant: 20
            ),
            habitButton.trailingAnchor.constraint(
                equalTo: verticalStackView.trailingAnchor,
                constant: -20
            )
        ])
    }
    
    func irregularEventButtonConstraintsActivate() {
        irregularEventButton.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            irregularEventButton.heightAnchor.constraint(
                equalToConstant: 60
            ),
            irregularEventButton.leadingAnchor.constraint(
                equalTo: verticalStackView.leadingAnchor,
                constant: 20
            ),
            irregularEventButton.trailingAnchor.constraint(
                equalTo: verticalStackView.trailingAnchor,
                constant: -20
            )
        ])
    }
}
