import UIKit

final class ScheduleViewController: UIViewController {
    
    // MARK: - Private Views
    private lazy var tableView: UITableView = {
        .init()
    }()
    private lazy var confirmButton: TrackerButton = {
        .init()
    }()
    
    // MARK: - Private Constants
    private let optionsManager = TrackerManager.shared
    
    // MARK: - View Life Cycles
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setUpViews()
    }
}

// MARK: - Extensions + Private ScheduleViewController Buttons Handlers
private extension ScheduleViewController {
    @objc func didTapConfirmButton() {
        NotificationCenter.default.post(
            name: .scheduleDidChangedNotification,
            object: self
        )
        navigationController?.popViewController(animated: true)
    }
    
    func didSelectWeekday(weekday: Weekday?) {
        guard
            let weekday,
            let index = optionsManager.weekdays.firstIndex(where: {$0.weekday == weekday})
        else { return }
        
        optionsManager.weekdays[index].isChoosen.toggle()
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
        
        cell.weekdayOption = optionsManager.weekdays[indexPath.row]
        cell.didSelectWeekday = didSelectWeekday
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
        navigationItem.title = "Расписание"
        
        configureTableView()
        configureConfirmButton()
        
        tableViewConstraintsActivate()
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
        
        tableView.backgroundColor = .clear
        tableView.separatorStyle = .none
        tableView.tableFooterView = nil
        tableView.tableHeaderView = nil
        tableView.layer.cornerRadius = 16
        tableView.clipsToBounds = true
        tableView.isScrollEnabled = false
    }
    
    func configureConfirmButton() {
        confirmButton.title = "Готово"
        confirmButton.addTarget(
            self,
            action: #selector(didTapConfirmButton),
            for: .touchUpInside
        )
    }
}

// MARK: - Extensions + Private ScheduleViewController Views Constraints Activation
private extension ScheduleViewController {
    func tableViewConstraintsActivate() {
        tableView.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(tableView)
        
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(
                equalTo: view.safeAreaLayoutGuide.topAnchor,
                constant: 24
            ),
            tableView.leadingAnchor.constraint(
                equalTo: view.leadingAnchor,
                constant: 16
            ),
            tableView.trailingAnchor.constraint(
                equalTo: view.trailingAnchor,
                constant: -16
            ),
            tableView.heightAnchor.constraint(
                equalToConstant: ViewsHeightConstant.tableViewCellHeight.rawValue * CGFloat(Weekday.allCases.count)
            )
        ])
    }
    
    func confirmButtonConstraintsActivate() {
        confirmButton.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(confirmButton)
        
        confirmButton.activateConstraints(
            view: view,
            position: .bottom
        )
    }
}
