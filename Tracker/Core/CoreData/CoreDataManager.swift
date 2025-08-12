import CoreData

final class CoreDataManager {
    
    // MARK: - Internal Static Instance of CoreDataManager [Singleton]
    static let shared = CoreDataManager()
    
    // MARK: - Private Initialization
    private init() {}
    
    // MARK: - Private Properties
    private lazy var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: GlobalConstants.coreDataLibraryName)
        container.loadPersistentStores(completionHandler: { (description, error) in
            if let error = error as NSError? {
                assertionFailure("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()
 
    // MARK: - Internal Properties
    @inlinable
    var context: NSManagedObjectContext {
        persistentContainer.viewContext
    }
}
