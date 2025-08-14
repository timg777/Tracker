import UIKit

final class TrackersViewController: UIViewController {
    
    // MARK: - Private Views
    private lazy var plusButton: UIButton = {
        .init()
    }()
    private lazy var datePicker: TrackerDatePicker = {
        .init()
    }()
    private lazy var habitsCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        let view =
        UICollectionView(
            frame: .zero,
            collectionViewLayout: layout
        )
        return view
    }()
    private lazy var noContentPlaceholderView: NoContentPlaceHolderView = {
        .init()
    }()
    private lazy var filtersButton: UIButton = {
        var config = UIButton.Configuration.filled()
        config.contentInsets = .init(top: 14, leading: 20, bottom: 14, trailing: 20)
        config.baseBackgroundColor = .ypBlue
        config.cornerStyle = .fixed
        config.background.cornerRadius = 16
        
        let button = UIButton(configuration: config)
        button.setAttributedTitle(
            NSAttributedString(
                string: localizedString(uiElement: .filtersButton),
                attributes:
                    [
                        .font: UIFont.ypRegular17,
                        .foregroundColor: UIColor.white
                    ]
            ),
            for: .normal
        )
        button.addTarget(self, action: #selector(filterButtonTapped), for: .touchUpInside)
        
        return button
    }()
    
    // MARK: - Private Constants
    private let reportManager = YMMYYandexMetricaReportManager.shared
    private let trackerViewModel = TrackerManager.shared.trackerViewModel
    private let trackerRecordViewModel = TrackerManager.shared.trackerRecordViewModel
    private let categoryViewModel = TrackerManager.shared.categoryViewModel
    
    // MARK: - Private Properties
    private var filterOption: FilterOption = .allTrackers {
        didSet {
            filterOptionsChangedHandler()
        }
    }
    private var filterButtonBottomConstraint: NSLayoutConstraint?
    
    // MARK: - Private Properties
    private var currentDate: Date = .now {
        didSet {
            guard filterOption != .trackersForToday else {
                filterOption = .allTrackers
                return
            }
            filterOptionsChangedHandler()
        }
    }
    
    // MARK: - View Life Cycles
    override func viewDidLoad() {
        super.viewDidLoad()
        
        addObservers()
        setUpViews()
        
        handleViewModelsEvents()
    }

    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}

// MARK: - Extensions + Priavate CategoryCreationViewController ViewModel Events Handling
private extension TrackersViewController {
    func handleViewModelsEvents() {
        trackerViewModel.onTrackersChanged = { [weak self] in
            self?.categoriesDidChanged()
        }
        trackerViewModel.onError = { [weak self] error in
            guard let self else { return }
            print("An error occurred: \(error)")
            reportManager.sendReport(
                reportTitle: "TrackerViewModel Error Report",
                errorString: error
            )
        }
        
        trackerRecordViewModel.trackerEntity = { [weak self] uuid in
            guard let self else { return nil }
            return trackerViewModel.trackerEntity(by: uuid)
        }
        trackerRecordViewModel.onError = { [weak self] error in
            guard let self else { return }
            print("An error occurred: \(error)")
            reportManager.sendReport(
                reportTitle: "TrackerRecordViewModel Error Report",
                errorString: error
            )
        }
        
        categoryViewModel.onCategoriesChanged = { [weak self] in
            self?.categoriesDidChanged()
        }
        categoryViewModel.onError = { [weak self] error in
            guard let self else { return }
            print("An error occurred: \(error)")
            reportManager.sendReport(
                reportTitle: "TrackerCategoryViewModel Error Report",
                errorString: error
            )
        }
    }
}

// MARK: - Extensions + Private TrackersViewController Helpers
private extension TrackersViewController {
    func addObservers() {
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
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(categoriesDidChanged),
            name: .categoriesDidChangedNotification,
            object: nil
        )
    }
    
    func localizedString(uiElement: LocalizationManager.UIElement.TrackersViewController) -> String {
        LocalizationManager.shared.localizedString(using: uiElement.rawValue)
    }
    func localizedString(shared: LocalizationManager.UIElement.Shared) -> String {
        LocalizationManager.shared.localizedString(using: shared.rawValue)
    }
    
    @objc private func categoriesDidChanged() {
        habitsCollectionView.reloadData()
        reloadNoContentPlaceholderView(with: .noSearchResults)
    }
    
    func reloadNoContentPlaceholderView(with type: NoContentType?) {
        guard trackerViewModel.wholeTrackersCount > 0
        else {
            noContentPlaceholderView.type = .noCategoriesFound
            noContentPlaceholderView.verticalStackView.isHidden = false
            return
        }
        let dataIsEmpty = habitsCollectionView.numberOfSections == 0
        noContentPlaceholderView.type = type
        noContentPlaceholderView.verticalStackView.isHidden = !dataIsEmpty
        
        let titleFilter = navigationItem.searchController?.searchBar.text ?? ""
        filtersButton.isHidden = trackerViewModel.trackerCountWithoutFilter(titleFilter: titleFilter, date: currentDate) == 0
    }
    
    func deleteTracker(at indexPath: IndexPath) {
        reportManager.sendActionReport(
            reportTitle: "User confirmed deletion of a tracker",
            event: .click,
            screenName: "Main",
            item: .delete
        )
        trackerViewModel.deleteTracker(at: indexPath)
        habitsCollectionView.reloadData()
        reloadNoContentPlaceholderView(with: .noSearchResults)
    }
    
    func clarifyTrackerDeletion(at indexPath: IndexPath) {
        let alert = UIAlertController(
            title: localizedString(uiElement: .alertTitle),
            message: nil,
            preferredStyle: .actionSheet
        )
        alert.addAction(
            .init(
                title: localizedString(shared: .cancel),
                style: .cancel,
                handler: { [weak self] _ in
                    guard let self else { return }
                    reportManager.sendActionReport(
                        reportTitle: "User cancelled deletion of a tracker",
                        event: .close,
                        screenName: "Main",
                        item: nil
                    )
                    alert.dismiss(animated: true)
                }
            )
        )
        alert.addAction(
            .init(
                title: localizedString(shared: .remove),
                style: .destructive,
                handler: { [weak self] _ in
                    self?.deleteTracker(at: indexPath)
                }
            )
        )
        
        present(alert, animated: true)
    }
}

// MARK: - Extensions + Private TrackersViewController Routing
private extension TrackersViewController {
    func showTrackerCreationViewController() {
        let trackerCreationViewController = TrackerCreationViewController()
        trackerCreationViewController.modalPresentationStyle = .pageSheet
        trackerCreationViewController.isModalInPresentation = false
        let navigationController = UINavigationController(rootViewController: trackerCreationViewController)
        present(
            navigationController,
            animated: true
        )
    }
    
    func showTrackersFilterViewController() {
        let filtersViewController = FiltersViewController(
            filter: filterOption) { [weak self] newOption in
                guard let self else { return }
                filterOption = newOption
            }
        filtersViewController.modalPresentationStyle = .pageSheet
        filtersViewController.isModalInPresentation = false
        
        let navigationController = UINavigationController(rootViewController: filtersViewController)
        present(
            navigationController,
            animated: true
        )
    }
}

// MARK: - Extensions + Private TrackersViewController Buttons Handlers
private extension TrackersViewController {
    @objc func filterButtonTapped() {
        showTrackersFilterViewController()
        reportManager.sendActionReport(
            reportTitle: "User tapped filter button",
            event: .click,
            screenName: "Main",
            item: .filter
        )
    }
    @objc func handlePlusButtonTapped() {
        showTrackerCreationViewController()
        reportManager.sendActionReport(
            reportTitle: "User tapped plus button",
            event: .click,
            screenName: "Main",
            item: .add_track
        )
    }
    
    @objc func keyboardWillShow(notification: Notification) {
        if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
            setCollectionViewContentInset(
                UIEdgeInsets(
                    top: 12,
                    left: 0,
                    bottom: keyboardSize.height - view.safeAreaInsets.bottom,
                    right: 0
                )
            )
        }
    }
    
    @objc func keyboardWillHide(notification: Notification) {
        setCollectionViewContentInset(
            UIEdgeInsets(
                top: 12,
                left: 0,
                bottom: 0,
                right: 0
            )
        )
    }
    
    private func setCollectionViewContentInset(_ inset: UIEdgeInsets) {
        view.isUserInteractionEnabled = false
        filterButtonBottomConstraint?.constant = -inset.bottom - 16
        UIView.animate(
            withDuration: 0.25,
            animations: { [weak self] in
                guard let self else { return }
                habitsCollectionView.contentInset = inset
                habitsCollectionView.contentInset.bottom += 70
                view.layoutIfNeeded()
            },
            completion: { [weak self] _ in
                self?.view.isUserInteractionEnabled = true
            }
        )
    }
}

// MARK: - Extensions + Internal TrackersViewController -> UICollectionViewDelegateFlowLayout Conformance
extension TrackersViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        referenceSizeForHeaderInSection section: Int
    ) -> CGSize {
        let category = categoryViewModel.fetchCategoryEntity(at: .init(item: section, section: 0))
        let trackersCount = category.trackers?.count ?? 0
        
        guard trackersCount > 0 else {
            return .init(width: collectionView.bounds.width, height: 0)
        }

        let title = category.name ?? ""
        let width = collectionView.bounds.width - 32
        let font = UIFont.ypMedium13
        let boundingRect = NSString(string: title).boundingRect(
            with: CGSize(width: width, height: .greatestFiniteMagnitude),
            options: [.usesLineFragmentOrigin],
            attributes: [.font: font],
            context: nil
        )

        let height = ceil(boundingRect.height) + (title.count > 29 ? 32 : 16)
        return CGSize(width: collectionView.bounds.width, height: max(height, 30))
    }

    
    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        sizeForItemAt indexPath: IndexPath
    ) -> CGSize {
        .init(
            width: (collectionView.bounds.width / 2) - 4.5,
            height: 148
        )
    }
    
    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        minimumInteritemSpacingForSectionAt section: Int
    ) -> CGFloat {
        9
    }
    
    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        insetForSectionAt section: Int
    ) -> UIEdgeInsets {
        .init(top: 12, left: 0, bottom: 0, right: 0)
    }
}

// MARK: - Extensions + Internal TrackersViewController -> UICollectionViewDelegate Conformance
extension TrackersViewController: UICollectionViewDelegate {
    func collectionView(
        _ collectionView: UICollectionView,
        viewForSupplementaryElementOfKind kind: String,
        at indexPath: IndexPath
    ) -> UICollectionReusableView {
        guard
            let view = collectionView.dequeueReusableSupplementaryView(
                ofKind: kind,
                withReuseIdentifier: TrackerSupplementaryView.reuseHeaderIdentifier,
                for: indexPath
            ) as? TrackerSupplementaryView,
            let title = trackerViewModel.sectionName(at: indexPath.section)
        else {
            return UICollectionReusableView()
        }
        
        view.title = title
        return view
    }
}

// MARK: - Extensions + Internal TrackersViewController -> UICollectionViewDataSource Conformnace
extension TrackersViewController: UICollectionViewDataSource {
    func collectionView(
        _ collectionView: UICollectionView,
        numberOfItemsInSection section: Int
    ) -> Int {
        trackerViewModel.numberOfItemsInSection(section)
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        trackerViewModel.numberOfSections
    }
    
    func collectionView(
        _ collectionView: UICollectionView,
        cellForItemAt indexPath: IndexPath
    ) -> UICollectionViewCell {
        let reuseIdentifier = TrackerCollectionCell.reuseIdentifier
        
        guard
            let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: reuseIdentifier,
                for: indexPath
            ) as? TrackerCollectionCell,
            let tracker = trackerViewModel.tracker(at: indexPath)
        else {
            return UICollectionViewCell()
        }
        
        cell.tracker = tracker
        cell.indexPath = indexPath
        cell.delegate = self
        return cell
    }
}

// MARK: - Extensions + TrackersViewController -> TrackerCollectionCellDelegate Conformnace
extension TrackersViewController: TrackerCollectionCellDelegate {
    func isTrackerPinned(uuid: UUID) -> Bool {
        trackerViewModel.isTrackerPinned(uuid: uuid)
    }
    
    func pinTracker(at indexPath: IndexPath?) {
        guard let indexPath else { return }
        trackerViewModel.pinTracker(indexPath: indexPath)
    }
    
    func unpinTracker(at indexPath: IndexPath?) {
        guard let indexPath else { return }
        trackerViewModel.unpinTracker(indexPath: indexPath)
    }
    
    func editTracker(at indexPath: IndexPath?) {
        guard
            let indexPath,
            let tracker = trackerViewModel.tracker(at: indexPath),
            let entity = trackerViewModel.trackerEntity(by: tracker.id),
            let title = entity.title,
            let emoji = entity.emoji,
            let hexColor = entity.hexColor,
            let color = UIColor(hex: hexColor),
            let categoryName = entity.category?.name
        else { return }
        
        let viewModel = TrackerCreationViewModel(
            model:
                .init(
                    id: tracker.id,
                    title: title,
                    emoji: emoji,
                    color: color,
                    categoryName: categoryName,
                    schedule: tracker.schedule
                )
        )
        
        let viewController = TrackerCreationOptionsViewController(
            viewModel: viewModel,
            isForEdit: true
        )
        viewController.navigationItem.hidesBackButton = true
        viewController.isIrregularEvent = tracker.schedule.isEmpty
        
        let navigationController = UINavigationController(rootViewController: viewController)
        navigationController.modalPresentationStyle = .formSheet
        present(navigationController, animated: true)
    }
    
    func tryDeleteTracker(at indexPath: IndexPath?) {
        guard let indexPath else { return }
        clarifyTrackerDeletion(at: indexPath)
    }
    
    func dateIsLessThanTodayDate() -> Bool {
        let calendar = Calendar.current
        return calendar.startOfDay(for: Date()) >= calendar.startOfDay(for: self.currentDate)
    }
    
    func toggleTrackerRecord(
        for uuid: UUID,
        updateWith indexPath: IndexPath
    ) {
        trackerRecordViewModel.toggleTrackerRecord(
            record:
                .init(
                    trackerId: uuid,
                    date: currentDate
                )
        )
        habitsCollectionView.reloadItems(at: [indexPath])
    }
    
    func trackerRecordsCount(for uuid: UUID) -> Int {
        trackerRecordViewModel.countTrackerRecords(for: uuid)
    }
    
    func isTrackerCompletedToday(uuid: UUID) -> Bool {
        trackerRecordViewModel.isTrackerCompleteToday(
            record:
                .init(
                    trackerId: uuid,
                    date: currentDate
                )
        )
    }
}

// MARK: - Extensions + Private TrackersViewController Setting Up Views
private extension TrackersViewController {
    func setUpViews() {
        view.backgroundColor = .mainViewBackground
        
        configurePlusButton()
        configureDatePicker()
        configureHabitsCollectionView()
        configureNavigationBar()
        
        habitsCollectionViewConstraintsActivate()
        filtersButtonConstraintsActivate()
        noContentPlaceholderViewConstraintsActivate()
        
        reloadNoContentPlaceholderView(with: .noSearchResults)
    }
}

extension TrackersViewController: DebouncedSearchControllerDelegate {
    func debouncedSearchController(didChangeSearchText text: String) {
        filterOptionsChangedHandler()
        habitsCollectionView.reloadData()
        /// - Выполняется hard reset для UICollectionView без анимации
        // TODO: - добавить .batchUpdates для UICollectionView для анимаций
    }
    
    func filterOptionsChangedHandler() {
        let trackerTitleFilter = navigationItem.searchController?.searchBar.text
        
        var onlyCompleted: Bool?
        switch filterOption {
        case .trackersForToday:
            datePicker.setDate(.now, animated: true)
            configureFilterButton(filterIsActive: false)
        case .completedTrackers:
            onlyCompleted = true
            configureFilterButton(filterIsActive: true)
        case .uncompletedTrackers:
            onlyCompleted = false
            configureFilterButton(filterIsActive: true)
        default:
            configureFilterButton(filterIsActive: false)
            break
        }
        
        trackerViewModel.updateFilterPredicate(
            trackerTitleFilter: trackerTitleFilter,
            onlyCompleted: onlyCompleted,
            dateFilter: currentDate
        )
        
        reloadNoContentPlaceholderView(with: .noSearchResults)
    }
}

// MARK: - Extensions + Private TrackersViewController Views Configuring
private extension TrackersViewController {
    func configureFilterButton(filterIsActive: Bool) {
        filtersButton.setAttributedTitle(
            NSAttributedString(
                string: localizedString(uiElement: .filtersButton),
                attributes:
                    [
                        .font: UIFont.ypRegular17,
                        .foregroundColor: filterIsActive ? UIColor.colorSelection1 : UIColor.white
                    ]
            ),
            for: .normal
        )
        filtersButton.configuration?.background.backgroundColor = filterIsActive ? #colorLiteral(red: 0.8627451062, green: 0.470588237, blue: 0.870588243, alpha: 0.4980392158) : .ypBlue
    }
    
    func configureNavigationBar() {
        navigationItem.hidesSearchBarWhenScrolling = false
        navigationController?.navigationBar.prefersLargeTitles = true
        title = localizedString(uiElement: .navigationTitle)
        
        navigationItem.leftBarButtonItem =
        UIBarButtonItem(
            customView: plusButton
        )
        navigationItem.leftBarButtonItem?.tintColor = .ypBlack
        
        navigationItem.rightBarButtonItem =
        UIBarButtonItem(
            customView: datePicker
        )
        
        let debouncedSearchController = DebouncedUISearchController(searchResultsController: nil)
        debouncedSearchController.debounceDelegate = self
        debouncedSearchController.debounce = 0.3
        navigationItem.searchController = debouncedSearchController
    }
    
    func configurePlusButton() {
        plusButton.setImage(
            UIImage(resource: .plus),
            for: .normal
        )
        
        plusButton.tintColor = .ypBlack
        plusButton.addTarget(
            self,
            action: #selector(handlePlusButtonTapped),
            for: .touchUpInside
        )
    }
    
    func configureDatePicker() {
        datePicker.dateWasChanged = { [weak self] date in
            guard let self else { return }
            currentDate = date
            habitsCollectionView.reloadData()
        }
    }
    
    func configureHabitsCollectionView() {
        habitsCollectionView.backgroundColor = .clear
        habitsCollectionView.scrollIndicatorInsets =
            .init(
                top: 0,
                left: 0,
                bottom: 0,
                right: -16
            )
        habitsCollectionView.contentInsetAdjustmentBehavior = .always
        habitsCollectionView.keyboardDismissMode = .interactive
        habitsCollectionView.alwaysBounceVertical = true
        habitsCollectionView.contentInset = .init(top: 0, left: 0, bottom: 70, right: 0)
        
        habitsCollectionView.delegate = self
        habitsCollectionView.dataSource = self
        habitsCollectionView.allowsMultipleSelection = false
        habitsCollectionView.register(
            TrackerCollectionCell.self,
            forCellWithReuseIdentifier: TrackerCollectionCell.reuseIdentifier
        )
        habitsCollectionView.register(
            TrackerSupplementaryView.self,
            forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
            withReuseIdentifier: TrackerSupplementaryView.reuseHeaderIdentifier
        )
    }
}

// MARK: - Extensions + Private TrackersViewController Views Constraints Activation
private extension TrackersViewController {
    func filtersButtonConstraintsActivate() {
        filtersButton.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(filtersButton)
        
        filterButtonBottomConstraint = filtersButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16)
        
        NSLayoutConstraint.activate([
            filtersButton.centerXAnchor.constraint(
                equalTo: view.centerXAnchor
            ),
            filterButtonBottomConstraint ?? filtersButton.bottomAnchor.constraint(
                equalTo: view.safeAreaLayoutGuide.bottomAnchor,
                constant: -16
            )
        ])
    }
    
    func noContentPlaceholderViewConstraintsActivate() {
        let placeholderView = noContentPlaceholderView.verticalStackView
        placeholderView.isHidden = true
        habitsCollectionView.addSubview(placeholderView)
        
        NSLayoutConstraint.activate([
            placeholderView.centerYAnchor.constraint(
                equalTo: habitsCollectionView.centerYAnchor
            ),
            placeholderView.centerXAnchor.constraint(
                equalTo: habitsCollectionView.centerXAnchor
            )
        ])
    }
    
    func plusButtonConstraintsActivate() {
        plusButton.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            plusButton.topAnchor.constraint(
                equalTo: view.safeAreaLayoutGuide.topAnchor
            ),
            plusButton.leadingAnchor.constraint(
                equalTo: view.safeAreaLayoutGuide.leadingAnchor,
                constant: 6
            ),
            plusButton.widthAnchor.constraint(equalToConstant: 44),
            plusButton.heightAnchor.constraint(equalTo: plusButton.widthAnchor)
        ])
    }
    
    func datePickerConstraintsActivate() {
        datePicker.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            datePicker.centerYAnchor.constraint(
                equalTo: plusButton.centerYAnchor
            ),
            datePicker.trailingAnchor.constraint(
                equalTo: view.safeAreaLayoutGuide.trailingAnchor,
                constant: -16
            )
        ])
    }
    
    func habitsCollectionViewConstraintsActivate() {
        habitsCollectionView.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(habitsCollectionView)
        
        NSLayoutConstraint.activate([
            habitsCollectionView.topAnchor.constraint(
                equalTo: view.safeAreaLayoutGuide.topAnchor
            ),
            habitsCollectionView.leadingAnchor.constraint(
                equalTo: view.safeAreaLayoutGuide.leadingAnchor,
                constant: 16
            ),
            habitsCollectionView.trailingAnchor.constraint(
                equalTo: view.safeAreaLayoutGuide.trailingAnchor,
                constant: -16
            ),
            habitsCollectionView.bottomAnchor.constraint(
                equalTo: view.safeAreaLayoutGuide.bottomAnchor
            )
        ])
    }
}
