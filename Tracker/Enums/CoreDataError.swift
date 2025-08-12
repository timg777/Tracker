import CoreData

enum CoreDataError: Error {
    case notFound(entityType: NSManagedObject.Type, param: String)
    case failedToDelete(entityType: NSManagedObject.Type)
}
