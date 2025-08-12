import CoreData

final class TrackerCategoryStore: NSObject {
    
    // MARK: - Internal Properties
    weak var delegate: TrackerCategoryStoreDelegate?
    
    // MARK: - Private Constants
    private let context: NSManagedObjectContext
    
    // MARK: - Private Properties
    private var insertedIndices: IndexSet?
    private var deletedIndices: IndexSet?
    
    private lazy var controller: NSFetchedResultsController<TrackerCategoryEntity> = {
        let fetchRequest = TrackerCategoryEntity.fetchRequest()
        
        fetchRequest.sortDescriptors = [
            .init(key: #keyPath(TrackerCategoryEntity.name), ascending: true)
        ]
        
        let controller = NSFetchedResultsController(
            fetchRequest: fetchRequest,
            managedObjectContext: context,
            sectionNameKeyPath: nil,
            cacheName: nil
        )
        
        controller.delegate = self
        
        do {
            try controller.performFetch()
        } catch {
            print("Failed to perform fetch: \(error)")
        }
        
        return controller
    }()
    
    init(context: NSManagedObjectContext = CoreDataManager.shared.context) {
        self.context = context
    }
}

// MARK: - Extensions + Internal TrackerCategoryStore Data Adding
extension TrackerCategoryStore {
    func addNewCategory(_ category: TrackerCategory) throws {
        let entity = TrackerCategoryEntity(context: context)
        entity.update(with: category.title)
        
        try context.save()
        performFetchResults()
    }
}

// MARK: - Extensions + Internal TrackerCategoryStore Data Editing
extension TrackerCategoryStore {
    func editCategory(at indexPath: IndexPath, name: String) throws {
        let entity = controller.object(at: indexPath)
        entity.update(with: name)
        
        try context.save()
        performFetchResults()
    }
}

// MARK: - Extensions + Internal TrackerCategoryStore Data Deletion
extension TrackerCategoryStore {
    func deleteCategory(at indexPath: IndexPath) throws {
        let entity = controller.object(at: indexPath)
        try deleteCategory(entity: entity)
    }
    
    func deleteCategory(for name: String) throws {
        guard let entity = try fetchCategoryEntity(for: name) else {
            throw CoreDataError.failedToDelete(entityType: TrackerCategoryEntity.self)
        }
        
        try deleteCategory(entity: entity)
    }
}

// MARK: - Extensions + Internal TrackerCategoryStore Data Getters
extension TrackerCategoryStore {
    func fetchCategoryEntity(at indexPath: IndexPath) -> TrackerCategoryEntity {
        controller.object(at: indexPath )
    }
    
    func fetchCategoriesEntities() -> [TrackerCategoryEntity] {
        controller.fetchedObjects ?? []
    }
    
    func fetchCategoryEntity(for name: String) throws -> TrackerCategoryEntity? {
        let fetchRequest = TrackerCategoryEntity.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "%K == %@", #keyPath(TrackerCategoryEntity.name), name)
        return try context.fetch(fetchRequest).first
    }
}

// MARK: - Extensions + Internal TrackerCategoryStore Helpers
extension TrackerCategoryStore {
    func performFetchResults() {
        do {
            try controller.performFetch()
        } catch {
            print("Failed to perform fetch: \(error)")
        }
    }
    
    func isNameUsed(name: String) -> Bool {
        let entities = controller.fetchedObjects ?? []
        return entities.contains(where: { $0.name == name })
    }
    
    var categoriesCount: Int? {
        controller.fetchedObjects?.count
    }
}

// MARK: - Extensions + Private TrackerCatagoryStore Helpers
private extension TrackerCategoryStore {
    func deleteCategory(entity: TrackerCategoryEntity) throws {
        context.delete(entity)
        
        try context.save()
        performFetchResults()
    }
}

// MARK: - Extensions + TrackerCategoryStore -> NSFetchedResultsControllerDelegate Conformance
extension TrackerCategoryStore: NSFetchedResultsControllerDelegate {
    func controllerDidChangeContent(
        _ controller: NSFetchedResultsController<any NSFetchRequestResult>
    ) {
        delegate?.didUpdate()
    }
}
