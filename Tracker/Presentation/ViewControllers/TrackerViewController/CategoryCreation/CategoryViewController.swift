import UIKit

final class CategoryViewController: UIViewController {
    // MARK: - Private Views
    private lazy var categoriesTableView: UITableView = {
        .init(
            frame: .zero,
            style: .insetGrouped
        )
    }()
    private lazy var addNewCategoryButton: TrackerButton = {
        .init()
    }()
    private lazy var noContentPlaceholderView: NoContentPlaceHolderView = {
        .init()
    }()
    
    // MARK: - Private Constants
    private let trackerManager = TrackerManager.shared
    
    // MARK: - View Life Cycles
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpViews()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        categoriesTableView.reloadData()

        if trackerManager.categoriesCount == 0 {
            addNoContentPlaceholderView()
        } else {
            noContentPlaceholderView.verticalStackView.removeFromSuperview()
        }
    }
}

// MARK: - Extensions + Private CategoryViewController Buttons Handlers
private extension CategoryViewController {
    @objc func didTapAddNewCategoryButton() {
        let viewController = CategoryCreationViewController()
        viewController.navigationItem.hidesBackButton = true
        navigationController?.pushViewController(viewController, animated: true)
    }
}

// MARK: - Extensions + Private CategoryViewController Helpers
private extension CategoryViewController {
    func routeToCategoryEditViewController(at: IndexPath) {
        let viewController = CategoryCreationViewController()
        viewController.navigationItem.hidesBackButton = true
        viewController.categoryIndexPath = at
        navigationController?.pushViewController(viewController, animated: true)
    }
    
    func removeCategory(at: IndexPath) {
        trackerManager.deleteCategory(at: at)
        categoriesTableView.deleteRows(
            at: [at],
            with: .top
        )
        
        if trackerManager.categoriesCount == 0 {
            addNoContentPlaceholderView()
        }
    }
}

// MARK: - Extensions + Internal CategoryViewController -> UITableViewDelegate Conformance
extension CategoryViewController: UITableViewDelegate {
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
        let categoryToSelect = trackerManager.fetchCategoryEntity(at: indexPath)
        let isCancelSelection = trackerManager.choosenCategory == categoryToSelect.name
        
        if isCancelSelection {
            trackerManager.choosenCategory = nil
        } else {
            trackerManager.choosenCategory = categoryToSelect.name
            NotificationCenter.default.post(
                name: .categoryDidChangedNotification,
                object: self
            )
            navigationController?.popViewController(animated: true)
        }
        
        for cell in tableView.visibleCells as? [CategoryOptionsCell] ?? [] {
            if cell.accessoryType == .checkmark {
                cell.accessoryType = .none
            }
        }
        
        if
            !isCancelSelection,
            let cell = tableView.cellForRow(
                at: indexPath
            ) as? CategoryOptionsCell
        {
            cell.accessoryType = .checkmark
        }
        
        tableView.deselectRow(
            at: indexPath,
            animated: true
        )
    }
    func tableView(
        _ tableView: UITableView,
        contextMenuConfigurationForRowAt indexPath: IndexPath,
        point: CGPoint
    ) -> UIContextMenuConfiguration? {
        guard trackerManager.categoriesCount > 0 else { return nil }
        
        return .init(actionProvider: { actions in
            return UIMenu(children: [
                UIAction(title: "Редактировать") { [weak self] _ in
                    self?.routeToCategoryEditViewController(at: indexPath)
                },
                UIAction(title: "Удалить", attributes: [.destructive]) { [weak self] _ in
                    self?.removeCategory(at: indexPath)
                },
            ])
        })
    }
}

// MARK: - Extensions + Internal CategoryViewController -> UITableViewDataSource Conformance
extension CategoryViewController: UITableViewDataSource {
    func tableView(
        _ tableView: UITableView,
        numberOfRowsInSection section: Int
    ) -> Int {
        trackerManager.categoriesCount
    }
    
    func tableView(
        _ tableView: UITableView,
        cellForRowAt indexPath: IndexPath
    ) -> UITableViewCell {
        let reuseIdentifier = CategoryOptionsCell.reuseIdentifier
        
        guard
            let cell = tableView.dequeueReusableCell(
                withIdentifier: reuseIdentifier,
                for: indexPath
            ) as? CategoryOptionsCell
        else {
            return UITableViewCell()
        }
        
        let categoryName = trackerManager.fetchCategoryEntity(at: indexPath).name
        
        cell.accessoryType = trackerManager.choosenCategory == categoryName ? .checkmark : .none
        cell.title = categoryName
        
        return cell
    }
}

// MARK: - Extensions + Private CategoryViewController Setting Up Views
private extension CategoryViewController {
    func setUpViews() {
        view.backgroundColor = .ypWhite
        navigationItem.title = "Категория"
        
        configureTableView()
        configureAddNewCategoryButton()
        
        trackerManager.categoriesCount == 0 ? addNoContentPlaceholderView() : ()
        addNewCategoryButtonConstraintsActivate()
        tableViewConstraintsActivate()
    }
}

// MARK: - Extensions + Private Views Configuring
private extension CategoryViewController {
    func configureTableView() {
        categoriesTableView.register(
            CategoryOptionsCell.self,
            forCellReuseIdentifier: CategoryOptionsCell.reuseIdentifier
        )
        categoriesTableView.dataSource = self
        categoriesTableView.delegate = self
        categoriesTableView.backgroundColor = .clear
        categoriesTableView.allowsSelection = true
        categoriesTableView.allowsMultipleSelection = false
        categoriesTableView.separatorStyle = .singleLine
        categoriesTableView.separatorInset =
        UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
        categoriesTableView.insetsContentViewsToSafeArea = false
        categoriesTableView.insetsLayoutMarginsFromSafeArea = false
    }
    
    func configureAddNewCategoryButton() {
        addNewCategoryButton.title = "Добавить категорию"
        addNewCategoryButton.addTarget(
            self,
            action: #selector(didTapAddNewCategoryButton),
            for: .touchUpInside
        )
    }
}

// MARK: - Extensions + Private CategoryViewController Constraints Activation
private extension CategoryViewController {
    func tableViewConstraintsActivate() {
        categoriesTableView.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(categoriesTableView)
        
        NSLayoutConstraint.activate([
            categoriesTableView.topAnchor.constraint(
                equalTo: view.safeAreaLayoutGuide.topAnchor,
                constant: 24
            ),
            categoriesTableView.leadingAnchor.constraint(
                equalTo: view.leadingAnchor,
                constant: -8
            ),
            categoriesTableView.trailingAnchor.constraint(
                equalTo: view.trailingAnchor,
                constant: 8
            ),
            categoriesTableView.bottomAnchor.constraint(
                equalTo: addNewCategoryButton.topAnchor,
                constant: -24
            )
        ])
    }
    
    func addNoContentPlaceholderView() {
        noContentPlaceholderView.title = "Привычки и события можно объединить по смыслу"
        
        view.addSubview(noContentPlaceholderView.verticalStackView)
        
        NSLayoutConstraint.activate([
            noContentPlaceholderView.verticalStackView.centerYAnchor.constraint(
                equalTo: view.centerYAnchor
            ),
            noContentPlaceholderView.verticalStackView.centerXAnchor.constraint(
                equalTo: view.centerXAnchor
            )
        ])
    }
    
    func addNewCategoryButtonConstraintsActivate() {
        addNewCategoryButton.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(addNewCategoryButton)
        
        addNewCategoryButton.activateConstraints(view: view, position: .bottom)
    }
}
