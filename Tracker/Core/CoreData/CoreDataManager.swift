import UIKit
import CoreData

final class CoreDataManager {
    
    static let shared = CoreDataManager()
    private init() {}
    
    private lazy var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: GlobalConstants.coreDataLibraryName)
        container.loadPersistentStores(completionHandler: { (description, error) in
            if let error = error as NSError? {
                assertionFailure("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()
 
    var context: NSManagedObjectContext {
        persistentContainer.viewContext
    }
    
    @inline(__always)
    func saveContext() throws {
        if context.hasChanges {
            try context.save()
        }
    }
}
