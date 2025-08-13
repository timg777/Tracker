import Foundation

typealias Binding<T> = (T) -> Void

final class CategoryViewModel {
    
    // MARK: - Private Constants
    private let model: TrackerCategoryStore
    
    // MARK: - Internal Properties
    var onCategoriesChanged: (() -> Void)?
    var onError: ((String) -> Void)?
    var selectedIndexPath: IndexPath? {
        guard
            let choosenCategory,
            let index = getCategoryIndex(for: choosenCategory)
        else { return nil }
        return IndexPath(row: index, section: 0)
    }
    
    // MARK: - Private(set) Properties
    private(set) var choosenCategory: String?
    
    // MARK: - Initialization
    init(
        model: TrackerCategoryStore,
        choosenCategory: String? = nil
    ) {
        self.model = model
        self.model.performFetchResults()
        self.choosenCategory = choosenCategory
    }
}

// MARK: - Extensions + Internal CategoryViewModel Category Selection
extension CategoryViewModel {
    func selectCategory(_ name: String?) {
        choosenCategory = name
    }
}

// MARK: - Extensions + Internal CategoryViewModel -> TrackerCategoryStoreDelegate Conformance
extension CategoryViewModel: TrackerCategoryStoreDelegate {
    func didUpdate() {
        onCategoriesChanged?()
    }
}

// MARK: - Internal CategoryViewModel Extensions
// MARK: - CollectionView Helpers
// MARK: - Categories Managment
extension CategoryViewModel {
    // MARK: - Category Data Getters
    @inline(__always)
    var categoriesCount: Int {
        model.categoriesCount ?? 0
    }
    func isCategoryNameExist(_ name: String) -> Bool {
        model.isNameUsed(name: name)
    }
    func fetchCategoryEntity(at indexPath: IndexPath) -> TrackerCategoryEntity {
        model.fetchCategoryEntity(at: indexPath)
    }
    @inline(__always)
    func fetchCategoriesEntities() -> [TrackerCategoryEntity] {
        model.fetchCategoriesEntities()
    }
    @inline(__always)
    func trackersCount(at indexPath: IndexPath) -> Int {
        model.fetchCategoryEntity(at: indexPath).trackers?.count ?? 0
    }
    func getCategoryIndex(for name: String?) -> Int? {
        guard let name else { return nil }
        let categories = model.fetchCategoriesEntities()
        guard !categories.isEmpty else { return nil }
        
        return categories.firstIndex { $0.name == name }
    }
    
    // MARK: - Category Creation
    func addNewCategory(name: String) {
        do {
            try model.addNewCategory(.init(title: name, trackers: []))
        } catch {
            onError?("Failed to add new category: \(error)")
        }
    }
    
    // MARK: - Category Update
    func editCategory(at indexPath: IndexPath, name: String) {
        do {
            try model.editCategory(at: indexPath, name: name)
        } catch {
            onError?("Failed to edit category: \(error)")
        }
    }
    
    // MARK: - Category deletion
    func deleteCategory(at indexPath: IndexPath) {
        do {
            try model.deleteCategory(at: indexPath)
        } catch {
            onError?("Failed to delete category: \(error)")
        }
    }
    func deleteCategory(for name: String) {
        do {
            try model.deleteCategory(for: name)
        } catch {
            onError?("Failed to delete category: \(error)")
        }
    }
}
