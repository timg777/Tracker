import CoreData

final class TrackerRecordStore {
    
    private let context: NSManagedObjectContext
    private let calendar = Calendar.current
    
    convenience init() {
        let context = CoreDataManager.shared.context
        self.init(context: context)
    }
    
    init(context: NSManagedObjectContext) {
        self.context = context
    }
    
    var records: [TrackerRecordEntity] {
        let fetchRequest = TrackerRecordEntity.fetchRequest()
        return (try? context.fetch(fetchRequest)) ?? []
    }
    
    func toggleTrackerRecord(record: TrackerRecord, with trackerEntity: TrackerEntity) throws {
        let date = calendar.startOfDay(for: record.date)
        
        let fetchRequest = TrackerRecordEntity.fetchRequest()
        
        let predicates: [NSPredicate] = [
            NSPredicate(
                format: "%K == %@",
                #keyPath(TrackerRecordEntity.date), date as NSDate
            ),
            NSPredicate(
                format: "tracker.trackerID == %@",
                record.trackerId as NSUUID
            )
        ]
        
        fetchRequest.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: predicates)
        
        let entities = try context.fetch(fetchRequest)
        
        if let existingEntity = entities.first {
            context.delete(existingEntity)
        } else {
            let recordEntity = TrackerRecordEntity(context: context)
            recordEntity.tracker = trackerEntity
            recordEntity.date = date
        }
        
        try context.save()
    }
    
    func countTrackerRecords(for uuid: UUID) throws -> Int {
        let fetchRequest = TrackerRecordEntity.fetchRequest()
        
        fetchRequest.predicate = NSPredicate(format: "%K == %@", #keyPath(TrackerRecordEntity.tracker.trackerID), uuid as NSUUID)
        
        let count = try context.count(for: fetchRequest)
        return count
    }
    
    func isTrackerCompleteToday(record: TrackerRecord) throws -> Bool {
        let fetchRequest = TrackerRecordEntity.fetchRequest()
        
        let predicates: [NSPredicate] = [
            .init(
                format: "%K == %@",
                #keyPath(TrackerRecordEntity.tracker.trackerID), record.trackerId as NSUUID
            ),
            .init(
                format: "%K == %@",
                #keyPath(TrackerRecordEntity.date), record.date as NSDate
            )
        ]
        
        fetchRequest.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: predicates)
        
        return try !context.fetch(fetchRequest).isEmpty
    }
}
