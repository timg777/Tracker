final class TrackerManager {
    
    static let shared = TrackerManager()
    
    private let trackerStore: TrackerStore
    private let categoryStore: TrackerCategoryStore
    private let trackerRecordStore: TrackerRecordStore
    
    private(set) lazy var trackerViewModel = TrackerViewModel(model: trackerStore)
    private(set) lazy var categoryViewModel = CategoryViewModel(model: categoryStore)
    private(set) lazy var trackerRecordViewModel = TrackerRecordViewModel(model: trackerRecordStore)
    
    private init() {
        
        let context = CoreDataManager.shared.context
        trackerStore = .init(context: context)
        categoryStore = .init(context: context)
        trackerRecordStore = .init()
        
        trackerStore.delegate = trackerViewModel
        categoryStore.delegate = categoryViewModel
        
        trackerStore.createDefaultCategory = { [weak self] in
            self?.createDefaultCategoryIfNeeded()
        }
        createDefaultCategoryIfNeeded()
    }
    
    private func createDefaultCategoryIfNeeded() {
        guard !categoryViewModel.isCategoryNameExist(
            GlobalConstants.defaultCategoryName
        ) else { return }
        categoryViewModel.addNewCategory(
            name: GlobalConstants.defaultCategoryName
        )
    }
}
