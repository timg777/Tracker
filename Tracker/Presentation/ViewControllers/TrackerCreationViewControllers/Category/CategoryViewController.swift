import UIKit

final class CategoryViewController: UIViewController {
    
    // MARK: - Private Views
    private lazy var categoriesTableView: TrackerTableView = {
        .init()
    }()
    private lazy var addNewCategoryButton: TrackerButton = {
        .init()
    }()
    private lazy var noContentPlaceholderView: NoContentPlaceHolderView = {
        .init()
    }()
    
    // MARK: - Private Constants
    private let viewModel = TrackerManager.shared.categoryViewModel
    
    // MARK: - View Life Cycles
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpViews()
        handleViewModelEvents()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        categoriesTableView.reloadData()

        reloadNoContentPlaceholderView()
    }
    
    private func localizedTitle(for uiElement: LocalizationManager.UIElement.Category) -> String {
        LocalizationManager.shared.localizedString(using: uiElement.rawValue)
    }
    private func localizedTitle(for shared: LocalizationManager.UIElement.Shared) -> String {
        LocalizationManager.shared.localizedString(using: shared.rawValue)
    }
}

// MARK: - Extensions + Private CategoryViewController ViewModel Events Handler
private extension CategoryViewController {
    func handleViewModelEvents() {
        viewModel.onCategoriesChanged = { [weak self] in
            guard let self else { return }
            categoriesTableView.reloadData()
        }
    }
}

// MARK: - Extensions + Private CategoryViewController Buttons Handlers
private extension CategoryViewController {
    @objc func didTapAddNewCategoryButton() {
        routeToCategoryViewController(isEditing: false)
    }
}

// MARK: - Extensions + Private CategoryViewController Helpers
private extension CategoryViewController {
    func reloadNoContentPlaceholderView() {
        let dataIsEmpty = viewModel.categoriesCount == 0
        noContentPlaceholderView.verticalStackView.isHidden = !dataIsEmpty
    }
    
    func routeToCategoryViewController(at: IndexPath? = nil, isEditing: Bool) {
        let viewController = CategoryCreationViewController()
        viewController.navigationItem.hidesBackButton = true
        viewController.categoryIndexPath = at
        navigationController?.pushViewController(viewController, animated: true)
    }
    
    func removeCategory(at: IndexPath) {
        viewModel.deleteCategory(at: at)
        reloadNoContentPlaceholderView()
    }
    
    func clarifyCategoryDeletion(at indexPath: IndexPath) {
        let alert = UIAlertController(
            title: localizedTitle(for: .alert),
            message: nil,
            preferredStyle: .actionSheet
        )
        alert.addAction(
            .init(
                title: localizedTitle(for: .cancel),
                style: .cancel,
                handler: { [weak self] _ in
                    guard let _ = self else { return }
                    alert.dismiss(animated: true)
                }
            )
        )
        alert.addAction(
            .init(
                title: localizedTitle(for: .remove),
                style: .destructive,
                handler: { [weak self] _ in
                    self?.removeCategory(at: indexPath)
                }
            )
        )
        
        present(alert, animated: true)
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
        let categoryToSelect = viewModel.fetchCategoryEntity(at: indexPath)
        let isCancelSelection = viewModel.choosenCategory == categoryToSelect.name
        
        guard let categoryName = categoryToSelect.name else { return }
        
        if isCancelSelection {
            viewModel.selectCategory(nil)
        } else {
            viewModel.selectCategory(categoryToSelect.name)
            NotificationCenter.default.post(
                name: .categoryDidChangedNotification,
                object: self,
                userInfo: ["categoryName": categoryName]
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
        guard viewModel.categoriesCount > 0 else { return nil }
        
        return .init(actionProvider: { [weak self] actions in
            guard let self else { return nil }
            return UIMenu(children: [
                UIAction(
                    title: localizedTitle(for: .edit)
                ) { [weak self] _ in
                    self?.routeToCategoryViewController(at: indexPath, isEditing: true)
                },
                UIAction(
                    title: localizedTitle(for: .remove),
                    attributes: [.destructive]
                ) { [weak self] _ in
                    self?.clarifyCategoryDeletion(at: indexPath)
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
        viewModel.categoriesCount
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
        
        let categoryName = viewModel.fetchCategoryEntity(at: indexPath).name
        
        cell.isLastItem = indexPath.row == viewModel.categoriesCount - 1
        cell.accessoryType = viewModel.choosenCategory == categoryName ? .checkmark : .none
        cell.title = categoryName
        
        return cell
    }
}

// MARK: - Extensions + Private CategoryViewController Setting Up Views
private extension CategoryViewController {
    func setUpViews() {
        view.backgroundColor = .ypWhite
        navigationItem.title = LocalizationManager.shared.localizedString(for: .category(.navigationTitle))
        
        configureTableView()
        configureAddNewCategoryButton()
        
        addNoContentPlaceholderView()
        addNewCategoryButtonConstraintsActivate()
        categoriesTableView.constraintsActivate(using: view, objectsCount: viewModel.categoriesCount)
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
    }
    
    func configureAddNewCategoryButton() {
        addNewCategoryButton.title = LocalizationManager.shared.localizedString(for: .category(.addCategoryButton))
        addNewCategoryButton.addTarget(
            self,
            action: #selector(didTapAddNewCategoryButton),
            for: .touchUpInside
        )
    }
}

// MARK: - Extensions + Private CategoryViewController Constraints Activation
private extension CategoryViewController {
    func addNoContentPlaceholderView() {
        noContentPlaceholderView.title = LocalizationManager.shared.localizedString(for: .noContentPlaceholder(.noCategoriesFound))
        noContentPlaceholderView.verticalStackView.isHidden = true
        
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
        
        addNewCategoryButton.activateConstraints(
            view: view,
            position: .bottom
        )
    }
}
