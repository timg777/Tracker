import CoreData

enum CoreDataError: Error {
    case notFound(entityType: NSManagedObject.Type, param: String)
    case failedToDelete(entityType: NSManagedObject.Type)
}

protocol TrackerStoreDelegate: AnyObject {
    func didUpdate(_ update: TrackerStoreUpdate)
}

struct TrackerStoreUpdate {
    let insertedIndices: IndexSet
    let deletedIndices: IndexSet
    let updatedIndices: IndexSet
    let movedIndices: [Move]
    let insertedSections: IndexSet
    let deletedSections: IndexSet
    
    struct Move {
        let oldSection: Int
        let oldIndex: Int
        let newSection: Int
        let newIndex: Int
    }
}

final class TrackerStore: NSObject {
    
    private let context: NSManagedObjectContext
    
    private var insertedIndices: IndexSet?
    private var deletedIndices: IndexSet?
    private var updatedIndices: IndexSet?
    private var movedIndices: [TrackerStoreUpdate.Move]?
    private var insertedSections: IndexSet?
    private var deletedSections: IndexSet?
    
    private lazy var controller: NSFetchedResultsController<TrackerEntity> = {
        let fetchRequest = TrackerEntity.fetchRequest()
        
        fetchRequest.sortDescriptors = [
            .init(key: #keyPath(TrackerEntity.title), ascending: true)
        ]
        
        let sectionNameKeyPath = #keyPath(TrackerEntity.category.name)
        
        let controller = NSFetchedResultsController(
            fetchRequest: fetchRequest,
            managedObjectContext: context,
            sectionNameKeyPath: sectionNameKeyPath,
            cacheName: nil
        )
        
        controller.delegate = self
        do {
            try controller.performFetch()
        } catch {
            print("Failed to perform initial fetch: \(error)")
        }
        
        return controller
    }()
    
    weak var delegate: TrackerStoreDelegate?
    
    convenience override init() {
        let context = CoreDataManager.shared.context
        self.init(context: context)
    }
    
    init(context: NSManagedObjectContext) {
        self.context = context
    }
    
    func performFetchResults() {
        do {
            try controller.performFetch()
        } catch {
            print("Failed to perform initial fetch: \(error)")
        }
    }
    
    func addNewTracker(_ tracker: TrackerModel, to categoryName: String) throws {
        let trackerEntity = TrackerEntity(context: context)
        trackerEntity.update(with: tracker)
        
        if let categoryEntity = try findCategory(named: categoryName) {
            trackerEntity.category = categoryEntity
        }
        
        try context.save()
        performFetchResults()
    }
    
    private func findCategory(named name: String) throws -> TrackerCategoryEntity? {
        let fetchRequest = TrackerCategoryEntity.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "%K == %@", #keyPath(TrackerCategoryEntity.name), name)
        
        do {
            return try context.fetch(fetchRequest).first
        } catch {
            throw CoreDataError.notFound(entityType: TrackerCategoryEntity.self, param: name)
        }
    }
    
    func deleteTracker(_ entity: TrackerEntity) throws {
        context.delete(entity)
        try context.save()
        performFetchResults()
    }
    
    var numberOfSections: Int {
        controller.sections?.count ?? 0
    }
    
    func numberOfItemsInSection(_ section: Int) -> Int {
        controller.sections?[safe: section]?.numberOfObjects ?? 0
    }
    
    var wholeTrackersCount: Int {
        let fetchRequest = TrackerEntity.fetchRequest()
        let count = try? context.count(for: fetchRequest)
        return count ?? 0
    }
    
    func tracker(at indexPath: IndexPath) -> TrackerModel? {
        let entity = controller.object(at: indexPath)
        return TrackerModel(entity: entity)
    }
    
    func trackerEntity(by uuid: UUID) throws -> TrackerEntity? {
        let fetchRequest = TrackerEntity.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "%K == %@", #keyPath(TrackerEntity.trackerID), uuid as NSUUID)
        return try context.fetch(fetchRequest).first
    }
    
    func sectionName(at index: Int) -> String? {
        controller.sections?[safe: index]?.name
    }
    
    func deleteTracker(at indexPath: IndexPath) throws {
        let entity = controller.object(at: indexPath)
        try deleteTracker(entity)
    }
    
    func updatePredicate(titleFilter: String?, date: Date) throws {
        let calendar = Calendar.current
        let date = calendar.startOfDay(for: date)

        let weekday = String(calendar.component(.weekday, from: date))
        
        NSFetchedResultsController<TrackerEntity>.deleteCache(withName: controller.cacheName)
        
        var predicates: [NSPredicate] = [
            .init(
                format: "%K CONTAINS[c] %@ OR %K == %@",
                #keyPath(TrackerEntity.schedule), weekday,
                #keyPath(TrackerEntity.schedule), ""
            )
        ]
        
        if let titleFilter, !titleFilter.isEmpty {
            predicates.append(
                .init(
                    format: "%K CONTAINS[c] %@",
                    #keyPath(TrackerEntity.title), titleFilter
                )
            )
        }
        controller.fetchRequest.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: predicates)
        
        try controller.performFetch()
        
        let update = TrackerStoreUpdate(
            insertedIndices: .init(),
            deletedIndices: .init(),
            updatedIndices: .init(),
            movedIndices: [],
            insertedSections: .init(),
            deletedSections: .init()
        )
        delegate?.didUpdate(update)
    }
}

extension TrackerStore: NSFetchedResultsControllerDelegate {
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<any NSFetchRequestResult>) {
        insertedIndices = .init()
        deletedIndices = .init()
        updatedIndices = .init()
        movedIndices = []
        insertedSections = .init()
        deletedSections = .init()
    }
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<any NSFetchRequestResult>) {
        guard
            let insertedIndices,
            let deletedIndices,
            let updatedIndices,
            let movedIndices,
            let insertedSections,
            let deletedSections
        else { return }
        
        delegate?.didUpdate(
            .init(
                insertedIndices: insertedIndices,
                deletedIndices: deletedIndices,
                updatedIndices: updatedIndices,
                movedIndices: movedIndices,
                insertedSections: insertedSections,
                deletedSections: deletedSections
            )
        )
        
        self.insertedIndices = nil
        self.deletedIndices = nil
        self.updatedIndices = nil
        self.movedIndices = []
        self.insertedSections = nil
        self.deletedSections = nil
    }
    
    func controller(
        _ controller: NSFetchedResultsController<any NSFetchRequestResult>,
        didChange anObject: Any,
        at indexPath: IndexPath?,
        for type: NSFetchedResultsChangeType,
        newIndexPath: IndexPath?
    ) {
        switch type {
        case .insert:
            if let newIndexPath {
                insertedIndices?.insert(newIndexPath.item)
            }
        case .delete:
            if let indexPath {
                deletedIndices?.insert(indexPath.item)
            }
        case .move:
            if let indexPath, let newIndexPath {
                movedIndices?.append(
                    .init(
                        oldSection: indexPath.section,
                        oldIndex: indexPath.item,
                        newSection: newIndexPath.section,
                        newIndex: newIndexPath.item
                    )
                )
            }
        case .update:
            if let indexPath {
                updatedIndices?.insert(indexPath.item)
            }
        @unknown default:
            break
        }
    }
    
    func controller(
        _ controller: NSFetchedResultsController<any NSFetchRequestResult>,
        didChange sectionInfo: any NSFetchedResultsSectionInfo,
        atSectionIndex sectionIndex: Int,
        for type: NSFetchedResultsChangeType
    ) {
        switch type {
        case .insert:
            insertedSections?.insert(sectionIndex)
        case .delete:
            deletedSections?.insert(sectionIndex)
        default:
            break
        }
    }
}
