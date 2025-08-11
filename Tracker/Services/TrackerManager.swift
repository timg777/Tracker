import UIKit

final class TrackerManager {
    
    static let shared = TrackerManager()
    private init() {
        trackerStore.delegate = self
        trackerCategoryStore.delegate = self
        
        createDefaultCategoryIfNeeded()
    }
    
    private let trackerStore = TrackerStore()
    private let trackerRecordStore = TrackerRecordStore()
    private let trackerCategoryStore = TrackerCategoryStore()
    
    // MARK: - Internal Properties
    var weekdays: [(weekday: Weekday, isChoosen: Bool)] = [
        (weekday: .monday, isChoosen: false),
        (weekday: .tuesday, isChoosen: false),
        (weekday: .wednesday, isChoosen: false),
        (weekday: .thursday, isChoosen: false),
        (weekday: .friday, isChoosen: false),
        (weekday: .saturday, isChoosen: false),
        (weekday: .sunday, isChoosen: false)
    ]
    
    var choosenCategory: String?
    
    func selectedOptions(for name: TrackerCreationOptionScreenItem.Name) -> String? {
        switch name {
        case .category:
            return choosenCategory
        case .schedule:
            let schedule = convertScheduleToString()
            return schedule.isEmpty ? nil : schedule
        }
    }
    
    private func createDefaultCategoryIfNeeded() {
        guard fetchCategoriesEntities().isEmpty else { return }
        
        addNewCategory(name: GlobalConstants.defaultCategoryName)
    }
}

extension TrackerManager: TrackerCategoryStoreDelegate, TrackerStoreDelegate {
    func didUpdate() {
        NotificationCenter.default.post(
            name: .categoriesDidChangedNotification,
            object: nil
        )
    }
    
    func didUpdate(_ update: TrackerStoreUpdate) {
        NotificationCenter.default.post(
            name: .categoriesDidChangedNotification,
            object: nil
        )
    }
}

// MARK: - Extensions + Internal TrackerManager CoollectionView Helpers
extension TrackerManager {
    
    // MARK: - Categories
    var categoriesCount: Int {
        trackerCategoryStore.categoriesCount ?? 0
    }
    func isCategoryNameExist(_ name: String) -> Bool {
        trackerCategoryStore.isNameUsed(name: name)
    }
    func fetchCategoryEntity(at indexPath: IndexPath) -> TrackerCategoryEntity {
        trackerCategoryStore.fetchCategoryEntity(at: indexPath)
    }
    func fetchCategoriesEntities() -> [TrackerCategoryEntity] {
        trackerCategoryStore.fetchCategoriesEntities()
    }
    func trackersCount(at indexPath: IndexPath) -> Int {
        trackerCategoryStore.fetchCategoryEntity(at: indexPath).trackers?.count ?? 0
    }
    func isNameUsed(name: String) -> Bool {
        trackerCategoryStore.isNameUsed(name: name)
    }
    func addNewCategory(name: String) {
        do {
            try trackerCategoryStore.addNewCategory(.init(title: name, trackers: []))
        } catch {
            print("Failed to add new category: \(error)")
        }
    }
    func editCategory(at indexPath: IndexPath, name: String) {
        do {
            try trackerCategoryStore.editCategory(at: indexPath, name: name)
        } catch {
            print("Failed to edit category: \(error)")
        }
    }
    func deleteCategory(at indexPath: IndexPath) {
        do {
            try trackerCategoryStore.deleteCategory(at: indexPath)
        } catch {
            print("Failed to delete category: \(error)")
        }
    }
    func deleteCategory(for name: String) {
        do {
            try trackerCategoryStore.deleteCategory(for: name)
        } catch {
            print("Failed to delete category: \(error)")
        }
    }
    
    // MARK: - Records
    func toggleTrackerRecord(record: TrackerRecord) {
        do {
            guard let trackerEntity = trackerEntity(by: record.trackerId) else {
                throw CoreDataError.notFound(entityType: TrackerEntity.self, param: record.trackerId.uuidString)
            }
            try trackerRecordStore.toggleTrackerRecord(record: record, with: trackerEntity)
        } catch {
            print("Failed to toggle tracker record: \(error)")
        }
    }
    func countTrackerRecords(for uuid: UUID) -> Int {
        do {
            return try trackerRecordStore.countTrackerRecords(for: uuid)
        } catch {
            print("Failed to count tracker records: \(error)")
            return 0
        }
    }
    func isTrackerCompleteToday(record: TrackerRecord) -> Bool {
        do {
            return try trackerRecordStore.isTrackerCompleteToday(record: record)
        } catch {
            print("Failed to check if tracker is complete today: \(error)")
            return false
        }
    }
    
    // MARK: - Trackers
    var wholeTrackersCount: Int {
        trackerStore.wholeTrackersCount
    }
    func addNewTracker(_ tracker: TrackerModel, to categoryName: String) {
        do {
            try trackerStore.addNewTracker(tracker, to: categoryName)
        } catch {
            print("Failed to add new tracker: \(error)")
        }
    }
    var numberOfSections: Int {
        trackerStore.numberOfSections
    }
    func numberOfItemsInSection(_ section: Int) -> Int {
        trackerStore.numberOfItemsInSection(section)
    }
    func tracker(at indexPath: IndexPath) -> TrackerModel? {
        trackerStore.tracker(at: indexPath)
    }
    func trackerEntity(by uuid: UUID) -> TrackerEntity? {
        do {
            return try trackerStore.trackerEntity(by: uuid)
        } catch {
            print("Failed to get tracker entity: \(error)")
            return nil
        }
    }
    func sectionName(at index: Int) -> String? {
        trackerStore.sectionName(at: index)
    }
    func deleteTracker(at indexPath: IndexPath) {
        do {
            try trackerStore.deleteTracker(at: indexPath)
        } catch {
            print("Failed to delete tracker: \(error)")
        }
    }
    func updateFilterPredicate(trackerTitleFilter: String?, dateFilter: Date) {
        do {
            try trackerStore.updatePredicate(titleFilter: trackerTitleFilter, date: dateFilter)
        } catch {
            print("Failed to update filter predicate: \(error)")
        }
    }
}

// MARK: - Extensions + Internal TrackerManager Helpers
extension TrackerManager {
    func convertScheduleToString() -> String {
        guard weekdays.contains(where: { $0.isChoosen }) else { return "" }
        
        guard weekdays.filter({ $0.isChoosen }).count < 7 else {
            return "Каждый день"
        }
        let sortedWeekdays = weekdays.filter({ $0.isChoosen }).sorted(by: {$0.weekday.rawValue < $1.weekday.rawValue})
        var resultString: String = ""
        for (index, weekdayOption) in sortedWeekdays.enumerated() {
            resultString += "\(weekdayOption.weekday.briefName)" + (index != sortedWeekdays.count - 1 ? ", " : "")
        }
        return resultString
    }
}
