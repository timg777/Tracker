import UIKit

final class ScheduleViewController: UIViewController {
    
    // MARK: - Private Views
    private lazy var tableView: TrackerTableView = {
        .init()
    }()
    private lazy var confirmButton: TrackerButton = {
        .init()
    }()
    
    // MARK: - Private Properties
    private(set) var weekdays = [Weekday]()
    
    // MARK: - View Life Cycles
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setUpViews()
    }
    
    func setWeekdays(_ weekdays: [Weekday]?) {
        self.weekdays = weekdays ?? []
        tableView.reloadData()
    }
}

// MARK: - Extensions + Private ScheduleViewController Buttons Handlers
private extension ScheduleViewController {
    @objc func didTapConfirmButton() {
        NotificationCenter.default.post(
            name: .scheduleDidChangedNotification,
            object: self,
            userInfo: ["schedule": weekdays]
        )
        
        navigationController?.popViewController(animated: true)
    }
    
    func didSelectWeekday(weekday: Weekday?) {
        guard let weekday else { return }
        weekdays.append(weekday)
        tableView.reloadData()
    }
    
    func didDeselectWeekday(weekday: Weekday?) {
        guard let weekday else { return }
        weekdays.removeAll { $0 == weekday }
        tableView.reloadData()
    }
}

// MARK: - Extensions + Internal ScheduleViewController -> UITableViewDataSource Conformance
extension ScheduleViewController: UITableViewDataSource {
    func tableView(
        _ tableView: UITableView,
        numberOfRowsInSection section: Int
    ) -> Int {
        return Weekday.allCases.count
    }
    
    func tableView(
        _ tableView: UITableView,
        cellForRowAt indexPath: IndexPath
    ) -> UITableViewCell {
        let reuseIdentifier = ScheduleOptionsCell.reuseIdentifier
        
        guard
            let cell = tableView.dequeueReusableCell(
                withIdentifier: reuseIdentifier,
                for: indexPath
            ) as? ScheduleOptionsCell
        else {
            return UITableViewCell()
        }
        
        if let weekday = Weekday.allCases[safe: indexPath.row] {
            cell.isOn = weekdays.contains(weekday)
            cell.weekday = weekday
        }
        cell.didSelectWeekday = didSelectWeekday
        cell.didDeselectWeekday = didDeselectWeekday
        cell.isLastItem = indexPath.row == Weekday.allCases.count - 1
        
        return cell
    }
}

// MARK: - Extensions + Internal ScheduleViewController -> UITableViewDelegate Conformance
extension ScheduleViewController: UITableViewDelegate {
    func tableView(
        _ tableView: UITableView,
        heightForRowAt indexPath: IndexPath
    ) -> CGFloat {
        ViewsHeightConstant.tableViewCellHeight.rawValue
    }
    
    func tableView(
        _ tableView: UITableView,
        shouldHighlightRowAt indexPath: IndexPath
    ) -> Bool {
        false
    }
}

// MARK: - Extensions + Private ScheduleViewController Setting Up Views
private extension ScheduleViewController {
    func setUpViews() {
        view.backgroundColor = .ypWhite
        navigationItem.title = LocalizationManager.shared.localizedString(for: .scheduleViewController(.navigationTitle))
        
        configureTableView()
        configureConfirmButton()
        
        tableView.constraintsActivate(using: view, objectsCount: 7)
        confirmButtonConstraintsActivate()
    }
}

// MARK: - Extensions + Private ScheduleViewController Views Configuring
private extension ScheduleViewController {
    func configureTableView() {
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(
            ScheduleOptionsCell.self,
            forCellReuseIdentifier: ScheduleOptionsCell.reuseIdentifier
        )
    }
    
    func configureConfirmButton() {
        confirmButton.title = LocalizationManager.shared.localizedString(for: .scheduleViewController(.confirmButton))
        confirmButton.addTarget(
            self,
            action: #selector(didTapConfirmButton),
            for: .touchUpInside
        )
    }
}

// MARK: - Extensions + Private ScheduleViewController Views Constraints Activation
private extension ScheduleViewController {
    func confirmButtonConstraintsActivate() {
        confirmButton.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(confirmButton)
        
        confirmButton.activateConstraints(
            view: view,
            position: .bottom
        )
    }
}
