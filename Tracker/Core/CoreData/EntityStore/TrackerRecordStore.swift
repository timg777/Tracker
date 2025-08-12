import CoreData

final class TrackerRecordStore {
    
    // MARK: - Private Constants
    private let context: NSManagedObjectContext
    private let calendar = Calendar.current
    
    // MARK: - Initialization
    init(context: NSManagedObjectContext = CoreDataManager.shared.context) {
        self.context = context
    }
}

// MARK: - Extensions + Internal TrackerRecordStore Data Managing
extension TrackerRecordStore {
    func deleteRecord(_ entity: TrackerRecordEntity) {
        context.delete(entity)
    }
    
    func saveContext() throws {
        guard context.hasChanges else { return }
        try context.save()
    }
    
    func createTrackerRecord(
        date: Date,
        relationship entity: TrackerEntity
    ) {
        let recordEntity = TrackerRecordEntity(context: context)
        recordEntity.tracker = entity
        recordEntity.date = date
    }
}

// MARK: - Extensions + Internal TrackerRecordStore Helpers
extension TrackerRecordStore {
    var records: [TrackerRecordEntity] {
        let fetchRequest = TrackerRecordEntity.fetchRequest()
        return (try? context.fetch(fetchRequest)) ?? []
    }
    
    func getFetchRequest(
        date: Date? = nil,
        trackerID: UUID
    ) -> NSFetchRequest<TrackerRecordEntity> {
        let fetchRequest = TrackerRecordEntity.fetchRequest()
        
        var predicates: [NSPredicate] = [
            NSPredicate(
                format: "%K == %@",
                #keyPath(TrackerRecordEntity.tracker.trackerID), trackerID as NSUUID
            )
        ]
        
        if let date {
            predicates.append(
                NSPredicate(
                    format: "%K == %@",
                    #keyPath(TrackerRecordEntity.date), date as NSDate
                )
            )
        }
        
        fetchRequest.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: predicates)
        
        return fetchRequest
    }
    
    func toggleTrackerRecord(
        record: TrackerRecord,
        with trackerEntity: TrackerEntity
    ) throws {
        let date = calendar.startOfDay(for: record.date)
        
        let fetchRequest = getFetchRequest(
            date: date,
            trackerID: record.trackerId
        )
        let entities = try context.fetch(fetchRequest)
        
        if let existingEntity = entities.first {
            deleteRecord(existingEntity)
        } else {
            createTrackerRecord(
                date: date,
                relationship: trackerEntity
            )
        }
        
        try saveContext()
    }
    
    func countTrackerRecords(for uuid: UUID) throws -> Int {
        let fetchRequest = getFetchRequest(trackerID: uuid)
        let count = try context.count(for: fetchRequest)
        return count
    }
    
    func isTrackerCompleteToday(record: TrackerRecord) throws -> Bool {
        let fetchRequest = getFetchRequest(
            date: record.date,
            trackerID: record.trackerId
        )
        return try !context.fetch(fetchRequest).isEmpty
    }
}
