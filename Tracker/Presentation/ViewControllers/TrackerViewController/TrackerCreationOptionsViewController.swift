import UIKit

final class TrackerCreationOptionsViewController: UIViewController {
    // MARK: - Private Views
    private lazy var titleLabel: UILabel = {
        .init()
    }()
    private lazy var textField: TrackerTextField = {
        .init()
    }()
    private lazy var availableTextRangeReachedLabel: UILabel = {
        .init()
    }()
    private lazy var tableView: UITableView = {
        .init()
    }()
    private lazy var confirmButton: TrackerButton = {
        .init()
    }()
    private lazy var cancelButton: TrackerButton = {
        .init()
    }()
    private lazy var scrollViewContainer: UIScrollView = {
        .init()
    }()
    
    // MARK: - Private Constants
    private let optionsManager = TrackerManager.shared
    
    // MARK: - Private Propetries
    private var confirmButtonBottomConstraint: NSLayoutConstraint?
    private var cancelButtonBottomConstraint: NSLayoutConstraint?
    private var warningBottomConstraint: NSLayoutConstraint?
    private var screenItems: [TrackerCreationOptionScreenItem] = [
        .init(
            name: .category,
            destinationController: CategoryViewController.self
        )
    ]
    
    // MARK: - Internal Properties
    var isIrregularEvent: Bool? {
        didSet {
            guard
                let isIrregularEvent,
                !isIrregularEvent
            else { return }
            screenItems.append(
                .init(
                    name: .schedule,
                    destinationController: ScheduleViewController.self
                )
            )
        }
    }
    
    // MARK: - View Life Cycles
    override func viewDidLoad() {
        super.viewDidLoad()
     
        addObservers()
        setUpViews()
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}

// MARK: - Extensions + Private TrackerCreationOptionsViewController -> UITextFieldDelegate Conformance
extension TrackerCreationOptionsViewController: UITextFieldDelegate {
    func textFieldShouldClear(_ textField: UITextField) -> Bool {
        warningBottomConstraint?.constant = 0
        UIView.animate(withDuration: 0.2) { [weak self] in
            guard let self else { return }
            availableTextRangeReachedLabel.layer.opacity = 0
            view.layoutIfNeeded()
        }
        checkForAllOptionFieldsAreCompleted(newTextValue: "")
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
        let updatedText = text.replacingCharacters(
            in: stringRange,
            with: string
        )
        
        let isOverLimit = updatedText.count > GlobalConstants.maximumTextLength
        
        if isOverLimit {
            warningBottomConstraint?.constant = 28
            UIView.animate(withDuration: 0.2) { [weak self] in
                guard let self else { return }
                availableTextRangeReachedLabel.layer.opacity = 1
                view.layoutIfNeeded()
                
            }
        } else {
            warningBottomConstraint?.constant = 0
            UIView.animate(withDuration: 0.2) { [weak self] in
                guard let self else { return }
                availableTextRangeReachedLabel.layer.opacity = 0
                view.layoutIfNeeded()
            }
        }
        
        checkForAllOptionFieldsAreCompleted(newTextValue: updatedText)
        return !isOverLimit
    }
}

// MARK: - Extensions + Private TrackerCreationOptionsViewController Buttons Actions Handlers
private extension TrackerCreationOptionsViewController {
    @objc func didTapConfirmButton() {
        guard
            let title = textField.text
        else { return }
        let schedule = optionsManager.weekdays.filter { $0.isChoosen }.map( \.weekday )
        
        optionsManager.createTracker(
            categoryTitle: optionsManager.choosenCategory ?? "По умолчанию",
            tracker: .init(
                id: .init(),
                title: title,
                emoji: "🏝️",
                color: UIColor.colorSelection18,
                schedule: schedule
            )
        )
        
        optionsManager.choosenCategory = nil
        
        dismiss(animated: true)
    }
    
    @objc func didTapCancelButton() {
        optionsManager.choosenCategory = nil
        dismiss(animated: true)
    }
}

// MARK: - Extensions + Private TrackerCreationOptionsViewController KeyboardEvent Hanlders
private extension TrackerCreationOptionsViewController {
    @objc func keyboardWillShow(notification: Notification) {
        if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
            setScrollViewContentInset(
                UIEdgeInsets(
                    top: 0,
                    left: 0,
                    bottom: keyboardSize.height - view.safeAreaInsets.bottom,
                    right: 0
                )
            )
        }
    }
    
    @objc func keyboardWillHide(notification: Notification) {
        setScrollViewContentInset(
            UIEdgeInsets(
                top: 0,
                left: 0,
                bottom: 0,
                right: 0
            )
        )
    }
    
    private func setScrollViewContentInset(_ inset: UIEdgeInsets) {
        let constant = inset.bottom == 0 ? 0 : -inset.bottom - view.safeAreaInsets.bottom + 16
        confirmButtonBottomConstraint?.constant = constant
        cancelButtonBottomConstraint?.constant = constant
        UIView.animate(
            withDuration: 0.25
        ) { [weak self] in
            self?.scrollViewContainer.contentInset = inset
            self?.view.layoutIfNeeded()
        }
    }
}

// MARK: - Extensions + Internal TrackerCreationOptionsViewController -> UITableViewDelegate Conformance
extension TrackerCreationOptionsViewController: UITableViewDelegate {
    func tableView(
        _ tableView: UITableView,
        didSelectRowAt indexPath: IndexPath
    ) {
        tableView.deselectRow(
            at: indexPath,
            animated: true
        )
        
        guard
            let screenItem = screenItems[safe: indexPath.row]
        else { return }
        let viewController = screenItem.destinationController.init()
        viewController.navigationItem.hidesBackButton = true
        
        navigationController?.pushViewController(viewController, animated: true)
    }

    func tableView(
        _ tableView: UITableView,
        heightForRowAt indexPath: IndexPath
    ) -> CGFloat {
        ViewsHeightConstant.tableViewCellHeight.rawValue
    }
}

// MARK: - Extensions + Internal TrackerCreationOptionsViewController -> UITableViewDataSource Conformance
extension TrackerCreationOptionsViewController: UITableViewDataSource {
    func tableView(
        _ tableView: UITableView,
        numberOfRowsInSection section: Int
    ) -> Int {
        screenItems.count
    }
    
    func tableView(
        _ tableView: UITableView,
        cellForRowAt indexPath: IndexPath
    ) -> UITableViewCell {
        
        let reuseIdentifier = DisclosureOptionTableCell.reuseIdentifier
        
        guard
            let cell = tableView.dequeueReusableCell(
                withIdentifier: reuseIdentifier,
                for: indexPath
            ) as? DisclosureOptionTableCell,
            let screenItem = screenItems[safe: indexPath.row]
        else {
            return UITableViewCell()
        }
        
        cell.screenItem = screenItem
        cell.isLastItem = indexPath.row == screenItems.count - 1
        cell.accessoryType = .disclosureIndicator

        if
            let selectedOptions = optionsManager.selectedOptions(for: screenItem.name)
        {
            cell.selectedOptions = selectedOptions
        }
        
        return cell
    }
}

// MARK: - Extensions + Private TrackerCreationOptionsViewController Setting Up Views
private extension TrackerCreationOptionsViewController {
    func setUpViews() {
        view.backgroundColor = .ypWhite
        
        configureTitleLabel()
        configureAvailableTextRangeReachedLabel()
        configureSearchField()
        configureConfirmButton()
        configureCancelButton()
        configureTableView()
        configureNavigationBar()
        configureScrollViewContainer()
        
        searchFieldConstraintsActivate()
        availableTextRangeReachedLabelConstraintsActivate()
        confirmButtonConstraintsActivate()
        cancelButtonConstraintsActivate()
        scrollViewContainerConstraintsActivate()
        tableViewConstraintsActivate()
    }
}

// MARK: - Extensions + Private TrackerCreationOptionsViewController Views Configuring
private extension TrackerCreationOptionsViewController {
    func configureAvailableTextRangeReachedLabel() {
        availableTextRangeReachedLabel.attributedText =
        NSAttributedString(
            string: "Ограничение 38 символов",
            attributes: [
                .font: UIFont.ypRegular17,
                .foregroundColor: UIColor.ypRed
            ]
        )
        availableTextRangeReachedLabel.layer.opacity = 0
        availableTextRangeReachedLabel.layer.zPosition = 0.9
    }
    func configureTableView() {
        tableView.allowsMultipleSelection = false
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(
            DisclosureOptionTableCell.self,
            forCellReuseIdentifier: DisclosureOptionTableCell.reuseIdentifier
        )
        
        tableView.backgroundColor = .background
        tableView.separatorStyle = .none
        tableView.tableFooterView = nil
        tableView.tableHeaderView = nil
        tableView.layer.cornerRadius = 16
        tableView.clipsToBounds = true
    }
    
    func configureNavigationBar() {
        navigationItem.titleView = titleLabel
    }
    
    func configureTitleLabel() {
        titleLabel.attributedText =
        NSAttributedString(
            string: (isIrregularEvent ?? false) ? "Новое нерегулярное событие" : "Новая привычка",
            attributes: [
                .font: UIFont.ypMedium16,
                .foregroundColor: UIColor.ypBlack
            ]
        )
    }
    
    func configureSearchField() {
        textField.placeholderText = "Введите название привычки"
        textField.delegate = self
    }
    
    func configureConfirmButton() {
        confirmButton.title = "Создать"
        confirmButton.isEnabled = false
        confirmButton.layer.opacity = 0.4
        confirmButton.addTarget(
            self,
            action: #selector(didTapConfirmButton),
            for: .touchUpInside
        )
    }
    
    func configureScrollViewContainer() {
        scrollViewContainer.showsVerticalScrollIndicator = false
        scrollViewContainer.showsHorizontalScrollIndicator = false
        scrollViewContainer.bounces = true
        scrollViewContainer.backgroundColor = .clear
        scrollViewContainer.keyboardDismissMode = .interactive
    }
    
    func configureCancelButton() {
        cancelButton.title = "Отменить"
        cancelButton.titleColor = .ypRed
        cancelButton.backgroundColor = .clear
        cancelButton.layer.borderColor = UIColor.ypRed.cgColor
        cancelButton.layer.borderWidth = 1
        cancelButton.addTarget(
            self,
            action: #selector(didTapCancelButton),
            for: .touchUpInside
        )
    }
}

// MARK: - Extensions + Private TrackerCreationOptionsViewController Constraints Activation
private extension TrackerCreationOptionsViewController {
    func availableTextRangeReachedLabelConstraintsActivate() {
        availableTextRangeReachedLabel.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(availableTextRangeReachedLabel)
        
        warningBottomConstraint = availableTextRangeReachedLabel.bottomAnchor.constraint(equalTo: textField.bottomAnchor)
        
        NSLayoutConstraint.activate([
            availableTextRangeReachedLabel.centerXAnchor.constraint(
                equalTo: view.centerXAnchor
            ),
            warningBottomConstraint ?? availableTextRangeReachedLabel.bottomAnchor.constraint(
                equalTo: textField.bottomAnchor
            )
        ])
    }
    
    func tableViewConstraintsActivate() {
        tableView.translatesAutoresizingMaskIntoConstraints = false
        
        scrollViewContainer.addSubview(tableView)
    
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(
                equalTo: scrollViewContainer.topAnchor
            ),
            tableView.leadingAnchor.constraint(
                equalTo: scrollViewContainer.leadingAnchor
            ),
            tableView.trailingAnchor.constraint(
                equalTo: scrollViewContainer.trailingAnchor
            ),
            tableView.widthAnchor.constraint(
                equalToConstant: view.bounds.width - 32
            ),
            tableView.heightAnchor.constraint(
                equalToConstant: ViewsHeightConstant.tableViewCellHeight.rawValue * CGFloat(screenItems.count)
            )
        ])
    }
    
    func scrollViewContainerConstraintsActivate() {
        scrollViewContainer.translatesAutoresizingMaskIntoConstraints = false

        view.addSubview(scrollViewContainer)
        
        NSLayoutConstraint.activate([
            scrollViewContainer.topAnchor.constraint(
                equalTo: availableTextRangeReachedLabel.bottomAnchor,
                constant: 24
            ),
            scrollViewContainer.leadingAnchor.constraint(
                equalTo: view.leadingAnchor,
                constant: 16
            ),
            scrollViewContainer.trailingAnchor.constraint(
                equalTo: view.trailingAnchor,
                constant: -16
            ),
            scrollViewContainer.bottomAnchor.constraint(
                equalTo: confirmButton.topAnchor,
                constant: 24
            )
        ])
    }
    
    func searchFieldConstraintsActivate() {
        textField.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(textField)
        
        NSLayoutConstraint.activate([
            textField.leadingAnchor.constraint(
                equalTo: view.leadingAnchor,
                constant: 16
            ),
            textField.trailingAnchor.constraint(
                equalTo: view.trailingAnchor,
                constant: -16
            ),
            textField.heightAnchor.constraint(
                equalToConstant: 75
            ),
            textField.topAnchor.constraint(
                equalTo: view.safeAreaLayoutGuide.topAnchor,
                constant: 38
            )
        ])
    }
    
    func confirmButtonConstraintsActivate() {
        confirmButton.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(confirmButton)
        
        confirmButtonBottomConstraint = confirmButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        
        NSLayoutConstraint.activate([
            confirmButton.leadingAnchor.constraint(
                equalTo: view.centerXAnchor,
                constant: 4
            ),
            confirmButton.trailingAnchor.constraint(
                equalTo: view.trailingAnchor,
                constant: -16
            ),
            confirmButtonBottomConstraint ?? confirmButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            confirmButton.heightAnchor.constraint(equalToConstant: ViewsHeightConstant.buttonHeight.rawValue)
        ])
    }
    
    func cancelButtonConstraintsActivate() {
        cancelButton.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(cancelButton)
        
        cancelButtonBottomConstraint = cancelButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        
        NSLayoutConstraint.activate([
            cancelButton.leadingAnchor.constraint(
                equalTo: view.leadingAnchor,
                constant: 16
            ),
            cancelButton.trailingAnchor.constraint(
                equalTo: view.centerXAnchor,
                constant: -4
            ),
            cancelButtonBottomConstraint ?? cancelButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            cancelButton.heightAnchor.constraint(equalToConstant: ViewsHeightConstant.buttonHeight.rawValue)
        ])
    }
}

// MARK: - Extensions + Private TrackerCreationOptionsViewController Helpers
private extension TrackerCreationOptionsViewController {
    func checkForAllOptionFieldsAreCompleted(newTextValue text: String = "DEFAULT") {
        let text = text == "DEFAULT" ? textField.text ?? "" : text
        let hasAtLeastOneDaySelected = optionsManager.weekdays.contains(where: { $0.isChoosen })
        let isSearchFieldEmpty = text.isEmpty
        
        let isButtonEnable = (hasAtLeastOneDaySelected || (isIrregularEvent ?? false)) && !isSearchFieldEmpty
        
        UIView.animate(withDuration: 0.2) { [weak self] in
            guard let self else { return }
            confirmButton.layer.opacity = isButtonEnable ? 1 : 0.4
            confirmButton.isEnabled = isButtonEnable
        }
    }
    
    func addObservers() {
        NotificationCenter.default.addObserver(
            forName: .scheduleDidChangedNotification,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            
            guard
                let self,
                let row = screenItems.firstIndex(where: { $0.name == .schedule })
            else { return }
            
            let schedule = optionsManager.convertScheduleToString()
            
            if
                let cell = tableView.cellForRow(
                    at: .init(
                        row: row,
                        section: 0
                    )
                ) as? DisclosureOptionTableCell
            {
                cell.selectedOptions = schedule
                checkForAllOptionFieldsAreCompleted()
            }
        }
        
        NotificationCenter.default.addObserver(
            forName: .categoryDidChangedNotification,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            guard
                let self,
                let row = screenItems.firstIndex(where: { $0.name == .category }),
                let category = optionsManager.choosenCategory
            else { return }
            if
                let cell = tableView.cellForRow(
                    at: .init(
                        row: row,
                        section: 0
                    )
                ) as? DisclosureOptionTableCell
            {
                cell.selectedOptions = category
                checkForAllOptionFieldsAreCompleted()
            }
        }
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardWillShow),
            name: UIResponder.keyboardWillShowNotification,
            object: nil
        )
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardWillHide),
            name: UIResponder.keyboardWillHideNotification,
            object: nil
        )
    }
}

