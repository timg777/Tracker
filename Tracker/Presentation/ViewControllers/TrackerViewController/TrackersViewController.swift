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
                schedule: [.monday, .wednesday, .friday]
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
    private lazy var categoriesToDisplay = trackerManager.categories {
        didSet {
            let isCategoriesToDisplayEmpty = categoriesToDisplay.isEmpty
            
            manageNoContentPlaceholderView(
                with: .noSearchResults,
                remove: !isCategoriesToDisplayEmpty,
                erasePreviousType: false
            )
            
            UIView.transition(
                with: habitsCollectionView,
                duration: 0.3,
                options: [.transitionCrossDissolve]
            ) { [weak self] in
                self?.habitsCollectionView.reloadData()
            }
        }
    }
    private var completedTrackers = [TrackerRecord]()
    private var currentDate: Date = .now
    
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
    }
    
    func manageNoContentPlaceholderView(
        with type: NoContentType,
        remove: Bool,
        erasePreviousType: Bool
    ) {
        if erasePreviousType {
            noContentPlaceholderView.type = nil
        }
        guard !remove else {
            UIView.animate(withDuration: 0.3) { [weak self] in
                self?.noContentPlaceholderView.verticalStackView.removeFromSuperview()
            }
            return
        }
        
        guard noContentPlaceholderView.type != type else { return }
        noContentPlaceholderView.verticalStackView.removeFromSuperview()
        noContentPlaceholderView.verticalStackView.layer.opacity = 0
        noContentPlaceholderView.type = type
        
        switch type {
        case .noSearchResults:
            noContentPlaceholderView.title = "Ничего не найдено"
            noContentPlaceholderView.image = UIImage(resource: .notFound)
        case .noCategoriesFound:
            noContentPlaceholderView.title = "Что будем отслеживать?"
            noContentPlaceholderView.image = UIImage(resource: .noStat)
        }
        
        view.addSubview(noContentPlaceholderView.verticalStackView)
        
        NSLayoutConstraint.activate([
            noContentPlaceholderView.verticalStackView.centerYAnchor.constraint(
                equalTo: view.centerYAnchor
            ),
            noContentPlaceholderView.verticalStackView.centerXAnchor.constraint(
                equalTo: view.centerXAnchor
            )
        ])
        
        view.isUserInteractionEnabled = false
        UIView.animate(
            withDuration: 0.3,
            animations: { [weak self] in
                self?.noContentPlaceholderView.verticalStackView.layer.opacity = 1
            },
            completion: { [weak self] _ in
                self?.view.isUserInteractionEnabled = true
            }
        )
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
        
        let indexPath = IndexPath(
            row: 0,
            section: section
        )
        
        guard
            let headerView = self.collectionView(
                collectionView,
                viewForSupplementaryElementOfKind: UICollectionView.elementKindSectionHeader,
                at: indexPath
            ) as? TrackerSupplementaryView
        else {
            return .zero
        }

        return headerView.systemLayoutSizeFitting(
            .init(
                width: collectionView.frame.width,
                height: (headerView.title?.count ?? 0) > 29 ? 50 : 30
            ),
            withHorizontalFittingPriority: .required,
            verticalFittingPriority: .fittingSizeLevel
        )
        
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
            let title = categoriesToDisplay[safe: indexPath.section]?.title
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
        categoriesToDisplay[safe: section]?.trackers.count ?? 0
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        categoriesToDisplay.count
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
            let tracker = categoriesToDisplay[safe: indexPath.section]?.trackers[safe: indexPath.item]
        else {
            return UICollectionViewCell()
        }
        
        let currentDateString = currentDate.convertToString(formatString: "dd.MM.yyyy")
        let isDayChecked =
        completedTrackers
            .filter {
                let idIsEqual = $0.trackerId == tracker.id
                let dateIsEqual = $0.dateString == currentDateString
                return idIsEqual && dateIsEqual
            }
            .count == 1
        
        cell.tracker = tracker
        cell.isDayChecked = isDayChecked
        
        cell.daysCheckedCount = completedTrackers.filter { $0.trackerId == tracker.id }.count
        cell.plusButtonTapped = { [weak self] in
            guard
                let self,
                Date.now >= currentDate
            else { return }
            if isDayChecked {
                completedTrackers.removeAll(where: { $0.trackerId == tracker.id && $0.dateString == currentDateString })
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
        
        trackerManager.categoriesDidChanged = { [weak self] in
            guard let self else { return }
            categoriesToDisplay = trackerManager.categories
        }
        
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
        searchTextDidChanged(to: searchController.searchBar.text)
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        manageNoContentPlaceholderView(
            with: .noCategoriesFound,
            remove: !trackerManager.categories.isEmpty,
            erasePreviousType: true
        )
    }
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        manageNoContentPlaceholderView(
            with: .noCategoriesFound,
            remove: true,
            erasePreviousType: false
        )
        searchTextDidChanged(to: "")
        categoriesToDisplay = trackerManager.categories
    }
    
    private func searchTextDidChanged(to text: String?) {
        guard
            let searchText = text,
            !searchText.isEmpty
        else {
            if categoriesToDisplay != trackerManager.categories {
                categoriesToDisplay = trackerManager.categories
            }
            return
        }

        let tmpCategories =
        trackerManager.categories
            .map { category -> TrackerCategory in
                let trackers = category.trackers.filter { $0.title.lowercased().contains(searchText.lowercased()) }
                if !trackers.isEmpty {
                    return .init(title: category.title, trackers: trackers)
                } else {
                    return .init(title: category.title, trackers: [])
                }
            }
        
        categoriesToDisplay = tmpCategories.filter { !$0.trackers.isEmpty }
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
