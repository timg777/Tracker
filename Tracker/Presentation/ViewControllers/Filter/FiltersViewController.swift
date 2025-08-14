import UIKit

final class FiltersViewController: UIViewController {
    
    // MARK: - Private Views
    private lazy var filtersTableView: TrackerTableView = {
        .init()
    }()
    
    // MARK: - Private Properties
    private var filter: FilterOption
    
    // MARK: - Private Constants
    private let didSelect: (FilterOption) -> Void
    
    // MARK: - View Life Cycles
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.title = LocalizationManager.shared.localizedString(for: .filter(.navigationTitle))
        view.backgroundColor = .ypWhite
        
        filtersTableView.delegate = self
        filtersTableView.dataSource = self
        filtersTableView.register(
            FilterOptionCell.self,
            forCellReuseIdentifier: FilterOptionCell.reuseIdentifier
        )
        
        filtersTableView.constraintsActivate(using: view, objectsCount: 4)
    }
    
    // MARK: - Internal Initialization
    init(
        filter: FilterOption,
        didSelect: @escaping (FilterOption) -> Void
    ) {
        self.filter = filter
        self.didSelect = didSelect
        
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension FiltersViewController: UITableViewDelegate {
    func tableView(
        _ tableView: UITableView,
        heightForRowAt indexPath: IndexPath
    ) -> CGFloat {
        ViewsHeightConstant.tableViewCellHeight.rawValue
    }
    
    func tableView(
        _ tableView: UITableView,
        didSelectRowAt indexPath: IndexPath
    ) {
        defer {
            dismiss(animated: true)
        }
        
        guard
            let filterToSelect = FilterOption.allCases[safe: indexPath.row],
            filter != filterToSelect
        else {
            return
        }
        
        didSelect(filterToSelect)
    }
}

extension FiltersViewController: UITableViewDataSource {
    func tableView(
        _ tableView: UITableView,
        numberOfRowsInSection section: Int
    ) -> Int {
        FilterOption.allCases.count
    }
    
    func tableView(
        _ tableView: UITableView,
        cellForRowAt indexPath: IndexPath
    ) -> UITableViewCell {
        let reuseIdentifier = FilterOptionCell.reuseIdentifier
        
        guard
            let cell = tableView.dequeueReusableCell(
                withIdentifier: reuseIdentifier,
                for: indexPath
            ) as? FilterOptionCell,
            let option = FilterOption.allCases[safe: indexPath.row]
        else {
            return UITableViewCell()
        }
        
        cell.isLastItem = indexPath.row == FilterOption.allCases.count - 1
        cell.option = option
        cell.accessoryType = filter == option ? .checkmark : .none
        
        return cell
    }
}
