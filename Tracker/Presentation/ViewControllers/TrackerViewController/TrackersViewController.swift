import UIKit

let mockCategories: [TrackerCategory] = [
    .init(
        title: "Домашний уют Домашний уют Домашний уют",
        trackers: [
            .init(
                id: .init(),
                title: "Поливать растения",
                emoji: "❤️",
                color: .colorSelection18,
                schedule: [.monday, .wednesday, .friday]
            )
        ]
    ),
    .init(
        title: "Радостные мелочи",
        trackers: [
            .init(
                id: .init(),
                title: "Кошка заслонила камеру на созвоне",
                emoji: "😻",
                color: .colorSelection2,
                schedule: [.tuesday, .thursday, .friday]
            ),
            .init(
                id: .init(),
                title: "Бабушка прислала открытку в вотсапе",
                emoji: "🌺",
                color: .colorSelection1,
                schedule: [.monday, .wednesday, .friday]
            ),
            .init(
                id: .init(),
                title: "Свидания в апреле",
                emoji: "❤️",
                color: .colorSelection14,
                schedule: [.monday, .wednesday, .friday]
            )
            ,
            .init(
                id: .init(),
                title: "Свидания в апреле",
                emoji: "❤️",
                color: .colorSelection14,
                schedule: [.monday, .wednesday, .friday]
            ),
            .init(
                id: .init(),
                title: "Свидания в апреле",
                emoji: "❤️",
                color: .colorSelection14,
                schedule: [.monday, .wednesday, .friday]
            )
        ]
    ),
]

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
    private var filteredCategoriesToDisplay: [TrackerCategory] {
        let dateFilter = currentDate
        let titleFilter = navigationItem.searchController?.searchBar.text?.lowercased() ?? ""
        
         return trackerManager.categories
            .map { category -> TrackerCategory in
                let trackers = category.trackers.filter { tracker -> Bool in
                    var isDateCorrect = false
                    var isTitleCorrect = false
                    
                    if tracker.schedule.isEmpty {
                        isDateCorrect = true
                    } else {
                        isDateCorrect = tracker.schedule.contains { weekday -> Bool in
                            let calendarWeekday = Calendar.current.component(.weekday, from: dateFilter)
                            return weekday.isEqual(to: calendarWeekday)
                        }
                    }
                    
                    if titleFilter.isEmpty {
                        isTitleCorrect = true
                    } else {
                        isTitleCorrect = tracker.title.lowercased().contains(titleFilter)
                    }

                    return isDateCorrect && isTitleCorrect
                }
                
                return .init(title: category.title, trackers: trackers)
            }
    }
    private var completedTrackers = [TrackerRecord]()
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
        filterOptionsChangedHandler()
        habitsCollectionView.reloadData()
    }
    
    func manageNoContentPlaceholderView(
        with type: NoContentType,
        remove: Bool,
        erasePreviousType: Bool
    ) {
        if erasePreviousType {
            noContentPlaceholderView.type = nil
        }
        
        noContentPlaceholderView.verticalStackView.removeFromSuperview()
        
        guard
            !remove || noContentPlaceholderView.type != type
        else {
            return
        }
        
        noContentPlaceholderView.type = type
        
        switch type {
        case .noSearchResults:
            noContentPlaceholderView.title = "Ничего не найдено"
            noContentPlaceholderView.image = UIImage(resource: .notFound)
        case .noCategoriesFound:
            noContentPlaceholderView.title = "Что будем отслеживать?"
            noContentPlaceholderView.image = UIImage(resource: .noStat)
        }
        
        habitsCollectionView.addSubview(noContentPlaceholderView.verticalStackView)
        
        NSLayoutConstraint.activate([
            noContentPlaceholderView.verticalStackView.centerYAnchor.constraint(
                equalTo: view.centerYAnchor
            ),
            noContentPlaceholderView.verticalStackView.centerXAnchor.constraint(
                equalTo: view.centerXAnchor
            )
        ])
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
        guard let category = filteredCategoriesToDisplay[safe: section] else {
            return .zero
        }

        guard !category.trackers.isEmpty else {
            return .init(width: collectionView.bounds.width, height: 0)
        }
        
        let title = category.title
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
            let categories = filteredCategoriesToDisplay[safe: indexPath.section]
        else {
            return UICollectionReusableView()
        }
        
        view.title = categories.trackers.isEmpty ? "" : categories.title
        return view
    }
}

// MARK: - Extensions + Internal TrackersViewController -> UICollectionViewDataSource Conformnace
extension TrackersViewController: UICollectionViewDataSource {
    func collectionView(
        _ collectionView: UICollectionView,
        numberOfItemsInSection section: Int
    ) -> Int {
        filteredCategoriesToDisplay[safe: section]?.trackers.count ?? 0
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        filteredCategoriesToDisplay.count
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
            let category = filteredCategoriesToDisplay[safe: indexPath.section],
            let tracker = category.trackers[safe: indexPath.item]
        else {
            return UICollectionViewCell()
        }
        
        let currentDateString = currentDate.convertToString(formatString: "dd.MM.yyyy")
        
        cell.tracker = tracker
        cell.isDayChecked = completedTrackers.contains {
            $0.trackerId == tracker.id && $0.dateString == currentDateString
        }
        cell.daysCheckedCount = completedTrackers.filter {
            $0.trackerId == tracker.id
        }.count
        cell.plusButtonTapped = { [weak self] in
            guard let self else { return }
            
            let calendar = Calendar.current
            guard calendar.startOfDay(for: Date()) >= calendar.startOfDay(for: self.currentDate) else { return }
            
            let isCurrentlyChecked = completedTrackers.contains {
                $0.trackerId == tracker.id && $0.dateString == currentDateString
            }
            
            if isCurrentlyChecked {
                completedTrackers.removeAll {
                    $0.trackerId == tracker.id && $0.dateString == currentDateString
                }
            } else {
                completedTrackers.append(
                    .init(
                        trackerId: tracker.id,
                        dateString: currentDateString
                    )
                )
            }
            collectionView.reloadItems(at: [indexPath])
        }
        return cell
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
        
        if trackerManager.categories.isEmpty {
            manageNoContentPlaceholderView(
                with: .noCategoriesFound,
                remove: false,
                erasePreviousType: true
            )
        }
        habitsCollectionViewConstraintsActivate()
    }
}

extension TrackersViewController: UISearchResultsUpdating, UISearchBarDelegate {
    func updateSearchResults(for searchController: UISearchController) {
        filterOptionsChangedHandler()
        habitsCollectionView.reloadData()
        /// - Выполняется hard reset для UICollectionView без анимации
        // TODO: - добавить .batchUpdates для UICollectionView для анимаций
    }
    
//    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
//        filterOptionsChangedHandler()
//    }
//    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
//        filterOptionsChangedHandler()
//    }
    
    func filterOptionsChangedHandler() {
        let categoriesIsEmpty = filteredCategoriesToDisplay.filter {
            !$0.trackers.isEmpty
        }.isEmpty
        
        manageNoContentPlaceholderView(
            with: .noCategoriesFound,
            remove: !categoriesIsEmpty,
            erasePreviousType: false
        )
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
