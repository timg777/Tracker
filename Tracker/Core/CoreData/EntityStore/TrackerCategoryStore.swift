import CoreData

protocol TrackerCategoryStoreDelegate: AnyObject {
    func didUpdate()
}

final class TrackerCategoryStore: NSObject {
    
    private let context: NSManagedObjectContext
    
    private var insertedIndices: IndexSet?
    private var deletedIndices: IndexSet?
    
    weak var delegate: TrackerCategoryStoreDelegate?
    
    convenience override init() {
        let context = CoreDataManager.shared.context
        self.init(context: context)
    }
    
    init(context: NSManagedObjectContext) {
        self.context = context
    }
    
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
    
    func addNewCategory(_ category: TrackerCategory) throws {
        let entity = TrackerCategoryEntity(context: context)
        entity.update(with: category.title)
        
        try context.save()
        performFetchResults()
    }
    
    func editCategory(at indexPath: IndexPath, name: String) throws {
        let entity = controller.object(at: indexPath)
        entity.update(with: name)
        
        try context.save()
        performFetchResults()
    }
    
    func deleteCategory(at indexPath: IndexPath) throws {
        let entity = controller.object(at: indexPath)
        try deleteCategory(entity: entity)
    }
    
    private func deleteCategory(entity: TrackerCategoryEntity) throws {
        context.delete(entity)
        
        try context.save()
        performFetchResults()
    }
    
    func deleteCategory(for name: String) throws {
        guard let entity = try fetchCategoryEntity(for: name) else {
            throw CoreDataError.failedToDelete(entityType: TrackerCategoryEntity.self)
        }
        
        try deleteCategory(entity: entity)
    }
    
    var categoriesCount: Int? {
        controller.fetchedObjects?.count
    }
    
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

extension TrackerCategoryStore: NSFetchedResultsControllerDelegate {
    func controllerDidChangeContent(
        _ controller: NSFetchedResultsController<any NSFetchRequestResult>
    ) {
        delegate?.didUpdate()
    }
}
