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
    private lazy var optionsCollectionView: UICollectionView = {
        let flowLayout = UICollectionViewFlowLayout()
        flowLayout.scrollDirection = .vertical
        let view = UICollectionView(frame: .zero, collectionViewLayout: flowLayout)
        return view
    }()
    private lazy var confirmButton: TrackerButton = {
        .init()
    }()
    private lazy var cancelButton: TrackerButton = {
        .init()
    }()
    private lazy var buttonsStackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [cancelButton, confirmButton])
        stackView.axis = .horizontal
        stackView.distribution = .fillEqually
        stackView.spacing = 8
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()
    
    private lazy var scrollViewContainer: UIScrollView = {
        .init()
    }()
    private lazy var containerView: UIView = {
        .init()
    }()
    
    // MARK: - Private Constants
    private let trackerManager = TrackerManager.shared
    
    // MARK: - Private Propetries
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
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        optionsCollectionView.layoutIfNeeded()
        
        let height = optionsCollectionView.contentSize.height
        optionsCollectionView.heightAnchor.constraint(equalToConstant: height).isActive = true
        
        containerView.layoutIfNeeded()
        scrollViewContainer.contentSize = containerView.bounds.size
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
            let collectionSelectionIndicies = optionsCollectionView.indexPathsForSelectedItems,
            let emojiIndexPath = collectionSelectionIndicies.first(where: { $0.section == 0 }),
            let colorIndexPath = collectionSelectionIndicies.first(where: { $0.section == 1 }),
            let emoji = TrackerCreationCollectionOptionCell.emojies[safe: emojiIndexPath.item],
            let color = TrackerCreationCollectionOptionCell.colors[safe: colorIndexPath.item]
        else { return }
        
        guard
            let title = textField.text
        else { return }
        let schedule = trackerManager.weekdays.filter { $0.isChoosen }.map( \.weekday )
        
        trackerManager.addNewTracker(
            .init(
                id: .init(),
                title: title,
                emoji: emoji,
                color: color,
                schedule: schedule
            ),
            to: trackerManager.choosenCategory ?? GlobalConstants.defaultCategoryName
        )
        
        trackerManager.choosenCategory = nil
        
        dismiss(animated: true)
    }
    
    @objc func didTapCancelButton() {
        trackerManager.choosenCategory = nil
        dismiss(animated: true)
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
            let selectedOptions = trackerManager.selectedOptions(for: screenItem.name)
        {
            cell.selectedOptions = selectedOptions
        }
        
        return cell
    }
}

// MARK: - Extensions + Internal TrackerCreationOptionsViewController -> UICollectionViewDelegate Conformance
extension TrackerCreationOptionsViewController: UICollectionViewDelegate {
    func collectionView(
        _ collectionView: UICollectionView,
        didSelectItemAt indexPath: IndexPath
    ) {
        guard let selectionIndexSets = collectionView.indexPathsForSelectedItems else { return }
        
        guard
            let currentSectionSelectionIndexPath = selectionIndexSets.first(where: {
                $0.section == indexPath.section && $0.item != indexPath.item
            })
        else {
            checkForAllOptionFieldsAreCompleted()
            return
        }
         
        collectionView.deselectItem(at: currentSectionSelectionIndexPath, animated: true)
        checkForAllOptionFieldsAreCompleted()
    }
    
    func collectionView(_ collectionView: UICollectionView, shouldDeselectItemAt indexPath: IndexPath) -> Bool {
        false
    }
}

// MARK: - Extensions + Internal TrackerCreationOptionsViewController -> UICollectionViewDataSource Conformance
extension TrackerCreationOptionsViewController: UICollectionViewDataSource {
    func collectionView(
        _ collectionView: UICollectionView,
        numberOfItemsInSection section: Int
    ) -> Int {
        18
    }
    
    func numberOfSections(
        in collectionView: UICollectionView
    ) -> Int {
        2
    }
    
    func collectionView(
        _ collectionView: UICollectionView,
        cellForItemAt indexPath: IndexPath
    ) -> UICollectionViewCell {
        guard
            let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: TrackerCreationCollectionOptionCell.reuseIdentifier,
                for: indexPath
            ) as? TrackerCreationCollectionOptionCell
        else {
            return UICollectionViewCell()
        }
        
        cell.cellType = indexPath.section == 0 ? .emoji(indexPath.item) : .color(indexPath.item)
        
        return cell
    }
    
    func collectionView(
        _ collectionView: UICollectionView,
        viewForSupplementaryElementOfKind kind: String,
        at indexPath: IndexPath
    ) -> UICollectionReusableView {
        guard
            let header = collectionView.dequeueReusableSupplementaryView(
                ofKind: kind,
                withReuseIdentifier: TrackerCreationCollectionOptionSectionHeaderView.reuseIdentifier,
                for: indexPath
            ) as? TrackerCreationCollectionOptionSectionHeaderView
        else {
            return UICollectionReusableView()
        }
        
        header.title = indexPath.section == 0 ? "Emoji" : "Цвет"
        
        return header
    }
}

// MARK: - Extensions + Internal TrackerCreationOptionsViewController -> UICollectionViewDelegateFlowLayout Conformance
extension TrackerCreationOptionsViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        sizeForItemAt indexPath: IndexPath
    ) -> CGSize {
        let availableWidth = collectionView.bounds.width - 36
        let cellSize = (availableWidth - 5 * 5) / 6
        return CGSize(width: cellSize, height: cellSize)
    }
    
    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        minimumLineSpacingForSectionAt section: Int
    ) -> CGFloat {
        5
    }
    
    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        minimumInteritemSpacingForSectionAt section: Int
    ) -> CGFloat {
        0
    }
    
    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        insetForSectionAt section: Int
    ) -> UIEdgeInsets {
        .init(top: 24, left: 18, bottom: 40, right: 18)
    }
    
    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        referenceSizeForHeaderInSection section: Int
    ) -> CGSize {
        .init(width: collectionView.bounds.width, height: 18)
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
        configureOptionsCollectionView()
        
        scrollViewContainerConstraintsActivate()
        containerViewConstraintsActivate()
        searchFieldConstraintsActivate()
        availableTextRangeReachedLabelConstraintsActivate()
        tableViewConstraintsActivate()
        optionsCollectionViewConstraintsActivate()
        buttonsStackViewConstraintsActivate()
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
    
    func configureOptionsCollectionView() {
        optionsCollectionView.delegate = self
        optionsCollectionView.dataSource = self
        optionsCollectionView.register(
            TrackerCreationCollectionOptionCell.self,
            forCellWithReuseIdentifier: TrackerCreationCollectionOptionCell.reuseIdentifier
        )
        optionsCollectionView.register(
            TrackerCreationCollectionOptionSectionHeaderView.self,
            forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
            withReuseIdentifier: TrackerCreationCollectionOptionSectionHeaderView.reuseIdentifier
        )
        optionsCollectionView.allowsMultipleSelection = true
        optionsCollectionView.isScrollEnabled = false
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
        
        containerView.addSubview(availableTextRangeReachedLabel)
        
        warningBottomConstraint = availableTextRangeReachedLabel.bottomAnchor.constraint(equalTo: textField.bottomAnchor)
        
        NSLayoutConstraint.activate([
            availableTextRangeReachedLabel.centerXAnchor.constraint(
                equalTo: containerView.centerXAnchor
            ),
            warningBottomConstraint ?? availableTextRangeReachedLabel.bottomAnchor.constraint(
                equalTo: textField.bottomAnchor
            )
        ])
    }
    
    func tableViewConstraintsActivate() {
        tableView.translatesAutoresizingMaskIntoConstraints = false
        
        containerView.addSubview(tableView)
    
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(
                equalTo: availableTextRangeReachedLabel.bottomAnchor,
                constant: 24
            ),
            tableView.leadingAnchor.constraint(
                equalTo: containerView.leadingAnchor,
                constant: 16
            ),
            tableView.trailingAnchor.constraint(
                equalTo: containerView.trailingAnchor,
                constant: -16
            ),
            tableView.heightAnchor.constraint(
                equalToConstant: ViewsHeightConstant.tableViewCellHeight.rawValue * CGFloat(screenItems.count)
            )
        ])
    }
    
    func optionsCollectionViewConstraintsActivate() {
        optionsCollectionView.translatesAutoresizingMaskIntoConstraints = false
        
        containerView.addSubview(optionsCollectionView)
        
        NSLayoutConstraint.activate([
            optionsCollectionView.topAnchor.constraint(
                equalTo: tableView.bottomAnchor,
                constant: 32
            ),
            optionsCollectionView.leadingAnchor.constraint(
                equalTo: view.leadingAnchor
            ),
            optionsCollectionView.trailingAnchor.constraint(
                equalTo: view.trailingAnchor
            )
        ])
    }
    
    func scrollViewContainerConstraintsActivate() {
        scrollViewContainer.translatesAutoresizingMaskIntoConstraints = false

        view.addSubview(scrollViewContainer)
        
        NSLayoutConstraint.activate([
            scrollViewContainer.topAnchor.constraint(
                equalTo: view.topAnchor
            ),
            scrollViewContainer.bottomAnchor.constraint(
                equalTo: view.bottomAnchor
            ),
            scrollViewContainer.leadingAnchor.constraint(
                equalTo: view.leadingAnchor
            ),
            scrollViewContainer.trailingAnchor.constraint(
                equalTo: view.trailingAnchor
            )
        ])
    }
    
    func containerViewConstraintsActivate() {
        containerView.translatesAutoresizingMaskIntoConstraints = false
        
        scrollViewContainer.addSubview(containerView)
        
        NSLayoutConstraint.activate([
            containerView.topAnchor.constraint(
                equalTo: scrollViewContainer.topAnchor
            ),
            containerView.bottomAnchor.constraint(
                equalTo: scrollViewContainer.bottomAnchor
            ),
            containerView.leadingAnchor.constraint(
                equalTo: scrollViewContainer.leadingAnchor
            ),
            containerView.trailingAnchor.constraint(
                equalTo: scrollViewContainer.trailingAnchor
            ),
            containerView.widthAnchor.constraint(
                equalTo: scrollViewContainer.widthAnchor
            )
        ])
    }
    
    func searchFieldConstraintsActivate() {
        textField.translatesAutoresizingMaskIntoConstraints = false
        
        containerView.addSubview(textField)
        
        NSLayoutConstraint.activate([
            textField.leadingAnchor.constraint(
                equalTo: containerView.leadingAnchor,
                constant: 16
            ),
            textField.trailingAnchor.constraint(
                equalTo: containerView.trailingAnchor,
                constant: -16
            ),
            textField.heightAnchor.constraint(
                equalToConstant: 75
            ),
            textField.topAnchor.constraint(
                equalTo: containerView.safeAreaLayoutGuide.topAnchor,
                constant: 38
            )
        ])
    }
    
    func buttonsStackViewConstraintsActivate() {
        buttonsStackView.translatesAutoresizingMaskIntoConstraints = false
        
        containerView.addSubview(buttonsStackView)
        
        NSLayoutConstraint.activate([
            buttonsStackView.heightAnchor.constraint(
                equalToConstant: ViewsHeightConstant.buttonHeight.rawValue
            ),
            buttonsStackView.topAnchor.constraint(
                equalTo: optionsCollectionView.bottomAnchor,
                constant: 16
            ),
            buttonsStackView.leadingAnchor.constraint(
                equalTo: containerView.leadingAnchor,
                constant: 20
            ),
            buttonsStackView.trailingAnchor.constraint(
                equalTo: containerView.trailingAnchor,
                constant: -20
            ),
            buttonsStackView.bottomAnchor.constraint(
                equalTo: containerView.bottomAnchor
            )
        ])
    }
}

// MARK: - Extensions + Private TrackerCreationOptionsViewController Helpers
private extension TrackerCreationOptionsViewController {
    func checkForAllOptionFieldsAreCompleted(newTextValue text: String = "DEFAULT") {
        let isTrackerNameValid = isTrackerNameValid(text == "DEFAULT" ? textField.text ?? "" : text)
        let isButtonEnabled = (hasAtLeastOneDaySelected || (isIrregularEvent ?? false)) && isTrackerNameValid && trackerOptionsSelected
        
        UIView.animate(withDuration: 0.2) { [weak self] in
            guard let self else { return }
            confirmButton.layer.opacity = isButtonEnabled ? 1 : 0.4
            confirmButton.isEnabled = isButtonEnabled
        }
    }
    
    func isTrackerNameValid(_ name: String) -> Bool {
        name.count > 0
    }
    
    var hasAtLeastOneDaySelected: Bool {
        trackerManager.weekdays.contains(where: { $0.isChoosen })
    }
    
    var trackerOptionsSelected: Bool {
        optionsCollectionView.indexPathsForSelectedItems?.count ?? 0 == 2
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
            
            let schedule = trackerManager.convertScheduleToString()
            
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
                let category = trackerManager.choosenCategory
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
    }
}

