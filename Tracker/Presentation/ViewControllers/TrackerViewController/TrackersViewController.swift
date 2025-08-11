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
    
    // MARK: - Private Constants
    private let trackerManager = TrackerManager.shared
    
    // MARK: - Private Properties
    private var currentDate: Date = .now {
        didSet {
            filterOptionsChangedHandler()
        }
    }
    
    // MARK: - View Life Cycles
    override func viewDidLoad() {
        super.viewDidLoad()
        
        addObservers()
        setUpViews()
        currentDate = .now
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
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
    
    @objc private func categoriesDidChanged() {
        habitsCollectionView.reloadData()
        reloadNoContentPlaceholderView(with: .noSearchResults)
    }
    
    func reloadNoContentPlaceholderView(with type: NoContentType?) {
        guard trackerManager.wholeTrackersCount > 0 else {
            noContentPlaceholderView.type = .noCategoriesFound
            noContentPlaceholderView.verticalStackView.isHidden = false
            return
        }
        let dataIsEmpty = habitsCollectionView.numberOfSections == 0
        noContentPlaceholderView.type = type
        noContentPlaceholderView.verticalStackView.isHidden = !dataIsEmpty
    }
}

// MARK: - Extensions + Internal TrackersViewController -> TrackerViewControllerProtocol Conformance
extension TrackersViewController {
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
}

// MARK: - Extensions + Private TrackersViewController Buttons Handlers
private extension TrackersViewController {
    @objc func handlePlusButtonTapped() {
        showTrackerCreationViewController()
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
        UIView.animate(
            withDuration: 0.25,
            animations: { [weak self] in
                self?.habitsCollectionView.contentInset = inset
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
        let category = trackerManager.fetchCategoryEntity(at: .init(item: section, section: 0))
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
            let title = trackerManager.sectionName(at: indexPath.section)
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
        trackerManager.numberOfItemsInSection(section)
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        trackerManager.numberOfSections
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
            let tracker = trackerManager.tracker(at: indexPath)
        else {
            return UICollectionViewCell()
        }
        
        cell.tracker = tracker
        cell.indexPath = indexPath
        cell.delegate = self
        return cell
    }
}

extension TrackersViewController: TrackerCollectionCellDelegate {
    func dateIsLessThanTodayDate() -> Bool {
        let calendar = Calendar.current
        return calendar.startOfDay(for: Date()) >= calendar.startOfDay(for: self.currentDate)
    }
    
    func toggleTrackerRecord(for uuid: UUID, updateWith indexPath: IndexPath) {
        trackerManager.toggleTrackerRecord(
            record: .init(trackerId: uuid, date: currentDate)
        )
        habitsCollectionView.reloadItems(at: [indexPath])
    }
    
    func trackerRecordsCount(for uuid: UUID) -> Int {
        trackerManager.countTrackerRecords(for: uuid)
    }
    
    func isTrackerCompletedToday(uuid: UUID) -> Bool {
        trackerManager.isTrackerCompleteToday(
            record: .init(trackerId: uuid, date: currentDate)
        )
    }
}

// MARK: - Extensions + Private TrackersViewController Setting Up Views
private extension TrackersViewController {
    func setUpViews() {
        view.backgroundColor = .background
        
        configurePlusButton()
        configureDatePicker()
        configureHabitsCollectionView()
        configureNavigationBar()
        
        habitsCollectionViewConstraintsActivate()
        noContentPlaceholderViewConstraintsActivate()
        
        reloadNoContentPlaceholderView(with: .noCategoriesFound)
    }
}

extension TrackersViewController: UISearchResultsUpdating, UISearchBarDelegate {
    func updateSearchResults(for searchController: UISearchController) {
        filterOptionsChangedHandler()
        habitsCollectionView.reloadData()
        /// - Выполняется hard reset для UICollectionView без анимации
        // TODO: - добавить .batchUpdates для UICollectionView для анимаций
    }
    
    func filterOptionsChangedHandler() {
        let trackerTitleFilter = navigationItem.searchController?.searchBar.text
        trackerManager.updateFilterPredicate(trackerTitleFilter: trackerTitleFilter, dateFilter: currentDate)
        reloadNoContentPlaceholderView(with: .noSearchResults)
    }
}

// MARK: - Extensions + Private TrackersViewController Views Configuring
private extension TrackersViewController {
    func configureNavigationBar() {
        navigationItem.hidesSearchBarWhenScrolling = false
        navigationController?.navigationBar.prefersLargeTitles = true
        title = "Трекеры"
        
        navigationItem.leftBarButtonItem =
        UIBarButtonItem(
            customView: plusButton
        )
        navigationItem.leftBarButtonItem?.tintColor = .ypBlack
        
        navigationItem.rightBarButtonItem =
        UIBarButtonItem(
            customView: datePicker
        )
        
        navigationItem.searchController = UISearchController(searchResultsController: nil)
        navigationItem.searchController?.searchResultsUpdater = self
        navigationItem.searchController?.searchBar.delegate = self
        navigationItem.searchController?.searchBar.placeholder = "Поиск"
        navigationItem.searchController?.hidesNavigationBarDuringPresentation = false
        navigationItem.searchController?.definesPresentationContext = true
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
