import CoreData
import Combine

final class CoreDataManager {
    
    // MARK: - Internal Static Instance of CoreDataManager [Singleton]
    static let shared = CoreDataManager()
    
    // MARK: - Private Initialization
    private init() {
        NotificationCenter.default.publisher(
            for: .NSManagedObjectContextObjectsDidChange,
            object: context
        )
        .sink { [weak self] _ in
            guard let self else { return }
            print("STATISTICS UPDATED")
            updateStatistics()
        }
        .store(in: &cancellables)
    }
    
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
    private var cancellables = Set<AnyCancellable>()
 
    // MARK: - Internal Properties
    @inlinable
    var context: NSManagedObjectContext {
        persistentContainer.viewContext
    }
    
    private func updateStatistics() {
        let statService = StatisticService.shared
        statService.averageDays = averageDaysCount
        statService.idealDays = idealDaysCount
        statService.bestPeriod = bestPeriodCount
        statService.completedTrackers = completedTrackersCount
        statService.didChanged?()
    }
    
    private var completedTrackersCount: Int {
        let fetchRequest = TrackerRecordEntity.fetchRequest()
        do {
            return try context.count(for: fetchRequest)
        } catch {
            print("Failed to fetch: \(error)")
            return 0
        }
    }
    
    private var averageDaysCount: Int {
        #warning("TODO: Implement average days count fetch")
        return 0
    }
    
    private var idealDaysCount: Int {
        #warning("TODO: Implement ideal days count fetch")
        return 0
    }
    
    private var bestPeriodCount: Int {
        #warning("TODO: Implement best period count fetch")
        return 0
    }
}
