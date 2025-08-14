final class TrackerManager {
    // MARK: - Internal Static Constants
    // MARK: - TrackerManager insance creation [singleton]
    static let shared = TrackerManager()
    
    private let trackerStore: TrackerStore
    private let categoryStore: TrackerCategoryStore
    private let trackerRecordStore: TrackerRecordStore
    
    // MARK: - Private(set) Properties
    private(set) lazy var trackerViewModel = TrackerViewModel(model: trackerStore)
    private(set) lazy var categoryViewModel = CategoryViewModel(model: categoryStore)
    private(set) lazy var trackerRecordViewModel = TrackerRecordViewModel(model: trackerRecordStore)
    
    // MARK: - Private Initialization
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
}

// MARK: - Extensions + Private TrackerManager Helpers
private extension TrackerManager {
    func createDefaultCategoryIfNeeded() {
        let categoryName = GlobalConstants.defaultCategoryName
        
        guard !categoryViewModel.isCategoryNameExist(categoryName) else { return }
        
        categoryViewModel.addNewCategory(
            name: categoryName
        )
    }
}
