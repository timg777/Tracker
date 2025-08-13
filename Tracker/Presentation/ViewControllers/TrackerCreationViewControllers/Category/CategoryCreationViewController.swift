import UIKit

final class CategoryCreationViewController: UIViewController {
    // MARK: - Private Views
    private lazy var textField: TrackerTextField = {
        .init()
    }()
    private lazy var confirmButton: TrackerButton = {
        .init()
    }()
    private lazy var warningLabel: UILabel = {
        .init()
    }()
    
    // MARK: - Private Propetries
    private var keyboardDismissGestureHub: KeyboardDismissGestureHub?
    private var warningBottomConstraint: NSLayoutConstraint?
    private var buttonsBottomConsraint: NSLayoutConstraint?
    
    // MARK: - Private Constants
    private let viewModel = TrackerManager.shared.categoryViewModel
    private let maximumTextLength: Int = 38
    
    // MARK: - Internal Properties
    var categoryIndexPath: IndexPath?
    
    // MARK: - View Life Cycles
    override func viewDidLoad() {
        super.viewDidLoad()

        keyboardDismissGestureHub = .init(view: self.view)
        keyboardDismissGestureHub?.keyboardHeightDidChange = { [weak self] height in
            guard let self else { return }
            buttonsBottomConsraint?.constant = height > 0 ? -height + view.safeAreaInsets.bottom - 16 : 0
            UIView.animate(withDuration: 0.3) { [weak self] in
                self?.view.layoutIfNeeded()
            }
        }
        setupViews()
        handleViewModelsEvents()
    }
}

// MARK: - Extensions + Priavate CategoryCreationViewController ViewModel Events Handling
private extension CategoryCreationViewController {
    func handleViewModelsEvents() {
        viewModel.onError = { [weak self] error in
            guard let _ = self else { return }
            print("An error occured: \(error)")
        }
        
        viewModel.onCategoriesChanged = { [weak self] in
            guard let _ = self else { return }
            print(#file, #function, "Categories changed")
        }
    }
}

// MARK: - Extensions + Private CategoryCreationViewController Buttons Handlers
private extension CategoryCreationViewController {
    @objc func didTapConfirmButton() {
        guard
            let text = textField.text
        else { return }
        
        if let categoryIndexPath {
            viewModel.editCategory(
                at: categoryIndexPath,
                name: text
            )
        } else {
            viewModel.addNewCategory(name: text)
        }

        navigationController?.popViewController(animated: true)
    }
}

// MARK: - Extensions + Internal CategoryCreationViewController -> UITextFieldDelegate Conformance
extension CategoryCreationViewController: UITextFieldDelegate {
    func textFieldShouldClear(_ textField: UITextField) -> Bool {
        confirmButton.makeInactive()
        warningBottomConstraint?.constant = 0
        UIView.animate(withDuration: 0.2) { [weak self] in
            guard let self else { return }
            warningLabel.layer.opacity = 0
            view.layoutIfNeeded()
        }
        return true
    }
    
    func textField(
        _ textField: UITextField,
        shouldChangeCharactersIn range: NSRange,
        replacementString string: String
    ) -> Bool {
        guard
            let text = textField.text,
            let stringRange = Range(range, in: text)
        else { return false }
        
        let updatedText =
        text.replacingCharacters(
            in: stringRange,
            with: string
        )
        
        let isOverLimit = updatedText.count > maximumTextLength
        let alreadyExists = viewModel.isCategoryNameExist(updatedText)
        
        if updatedText.isEmpty || (!updatedText.isEmpty && alreadyExists) {
            confirmButton.makeInactive()
        } else {
            confirmButton.makeActive()
        }
        
        if isOverLimit || alreadyExists {
            warningLabel.attributedText =
            NSAttributedString(
                string: isOverLimit ? "Ограничение 38 символов" : "Такая категория уже существует",
                attributes: [
                    .font: UIFont.ypRegular17,
                    .foregroundColor: UIColor.ypRed
                ]
            )
            warningBottomConstraint?.constant = 28
            UIView.animate(withDuration: 0.2) { [weak self] in
                guard let self else { return }
                warningLabel.layer.opacity = 1
                view.layoutIfNeeded()
                
            }
        } else {
            warningBottomConstraint?.constant = 0
            UIView.animate(withDuration: 0.2) { [weak self] in
                guard let self else { return }
                warningLabel.layer.opacity = 0
                view.layoutIfNeeded()
            }
        }
        
        return !isOverLimit
    }
}

// MARK: - Extensions + Private CategoryCreationViewController Setting Up Views
private extension CategoryCreationViewController {
    func setupViews() {
        view.backgroundColor = .ypWhite
        navigationItem.title = categoryIndexPath == nil ? "Новая категория" : "Редактирование категории"
        
        configureTextField()
        configureConfirmButton()
        configureWarningLabel()
        
        textFieldConstraintsActivate()
        confirmButtonConstraintsActivate()
        availableTextRangeReachedLabelConstraintsActivate()
    }
}

// MARK: - Extensions + Private CategoryCreationViewController Views Configuring
private extension CategoryCreationViewController {
    func configureTextField() {
        textField.placeholderText = "Введите навзвание категории"
        textField.delegate = self
        textField.layer.zPosition = 1
        
        guard let categoryIndexPath else { return }
        let entity = viewModel.fetchCategoryEntity(at: categoryIndexPath)
        textField.text = entity.name
    }
    
    func configureConfirmButton() {
        confirmButton.title = "Готово"
        confirmButton.makeInactive()
        confirmButton.addTarget(
            self,
            action: #selector(didTapConfirmButton),
            for: .touchUpInside
        )
    }
    
    func configureWarningLabel() {
        warningLabel.layer.opacity = 0
        warningLabel.layer.zPosition = 0.9
    }
}

// MARK: - Extensions + Private CategoryCreationViewController Constraints Activation
private extension CategoryCreationViewController {
    func availableTextRangeReachedLabelConstraintsActivate() {
        warningLabel.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(warningLabel)
        
        warningBottomConstraint = warningLabel.bottomAnchor.constraint(equalTo: textField.bottomAnchor)
        
        NSLayoutConstraint.activate([
            warningLabel.centerXAnchor.constraint(
                equalTo: view.centerXAnchor
            ),
            warningBottomConstraint ?? warningLabel.bottomAnchor.constraint(
                equalTo: textField.bottomAnchor
            )
        ])
    }
    
    func textFieldConstraintsActivate() {
        textField.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(textField)
        
        textField.activateConstraints(view: view)
    }
    
    func confirmButtonConstraintsActivate() {
        confirmButton.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(confirmButton)
        
        buttonsBottomConsraint = confirmButton.bottomAnchor.constraint(
            equalTo: view.safeAreaLayoutGuide.bottomAnchor
        )
        
        NSLayoutConstraint.activate([
            confirmButton.heightAnchor.constraint(
                equalToConstant: ViewsHeightConstant.buttonHeight.rawValue
            ),
            buttonsBottomConsraint ?? confirmButton.bottomAnchor.constraint(
                equalTo: view.safeAreaLayoutGuide.bottomAnchor
            ),
            confirmButton.leadingAnchor.constraint(
                equalTo: view.leadingAnchor,
                constant: 16
            ),
            confirmButton.trailingAnchor.constraint(
                equalTo: view.trailingAnchor,
                constant: -16
            )
        ])
    }
}
