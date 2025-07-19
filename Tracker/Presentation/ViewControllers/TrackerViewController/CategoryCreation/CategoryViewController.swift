import UIKit

final class CategoryViewController: UIViewController {
    // MARK: - Private Views
    private lazy var tableView: UITableView = {
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
    private let optionsManager = TrackerManager.shared
    
    // MARK: - View Life Cycles
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpViews()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tableView.reloadData()

        if optionsManager.categories.isEmpty {
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
    func editCategory(at: IndexPath) {
        let viewCpntroller = CategoryCreationViewController()
        viewCpntroller.navigationItem.hidesBackButton = true
        viewCpntroller.categoryToEdit = optionsManager.categories.map(\.title)[at.item]
        navigationController?.pushViewController(viewCpntroller, animated: true)
    }
    
    func removeCategory(at: IndexPath) {
        optionsManager.categories.remove(at: at.section)
        tableView.deleteRows(
            at: [at],
            with: .top
        )
        
        if optionsManager.categories.isEmpty {
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
        guard
            let categoryToSelect = optionsManager.categories[safe: indexPath.row]
        else { return }
        let isCancelSelection = optionsManager.choosenCategory == categoryToSelect.title
        
        if optionsManager.choosenCategory == categoryToSelect.title {
            optionsManager.choosenCategory = nil
        } else {
            optionsManager.choosenCategory = categoryToSelect.title
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
        guard !optionsManager.categories.isEmpty else { return nil }
        
        return .init(actionProvider: { actions in
            return UIMenu(children: [
                UIAction(title: "Редактировать") { [weak self] _ in
                    self?.editCategory(at: indexPath)
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
        optionsManager.categories.count
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
        
        let category = optionsManager.categories[safe: indexPath.row]
        
        cell.accessoryType = optionsManager.choosenCategory == category?.title ? .checkmark : .none
        cell.title = category?.title
        
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
        
        optionsManager.categories.isEmpty ? addNoContentPlaceholderView() : ()
        addNewCategoryButtonConstraintsActivate()
        tableViewConstraintsActivate()
    }
}

// MARK: - Extensions + Private Views Configuring
private extension CategoryViewController {
    func configureTableView() {
        tableView.register(
            CategoryOptionsCell.self,
            forCellReuseIdentifier: CategoryOptionsCell.reuseIdentifier
        )
        tableView.dataSource = self
        tableView.delegate = self
        tableView.backgroundColor = .clear
        tableView.allowsSelection = true
        tableView.allowsMultipleSelection = false
        tableView.separatorStyle = .singleLine
        tableView.separatorInset =
        UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
        tableView.insetsContentViewsToSafeArea = false
        tableView.insetsLayoutMarginsFromSafeArea = false
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
        tableView.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(tableView)
        
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(
                equalTo: view.safeAreaLayoutGuide.topAnchor,
                constant: 24
            ),
            tableView.leadingAnchor.constraint(
                equalTo: view.leadingAnchor,
                constant: -8
            ),
            tableView.trailingAnchor.constraint(
                equalTo: view.trailingAnchor,
                constant: 8
            ),
            tableView.bottomAnchor.constraint(
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
