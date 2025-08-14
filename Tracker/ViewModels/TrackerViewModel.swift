import Foundation

final class TrackerViewModel {
    
    // MARK: - Private Constants
    private let model: TrackerStore
    
    // MARK: - Internal Properties
    var onTrackersChanged: (() -> Void)?
    var onError: ((String) -> Void)?
    
    // MARK: - Initialization
    init(
        model: TrackerStore
    ) {
        self.model = model
        self.model.performFetchResults()
    }
}

// MARK: - Extensions + Internal CategoryViewModel -> TrackerCategoryStoreDelegate Conformance
extension TrackerViewModel: TrackerStoreDelegate {
    func didUpdate(_ update: TrackerStoreUpdate) {
        onTrackersChanged?()
    }
}

// MARK: - Internal TrackerViewModel Extensions
// MARK: - CollectionView Helpers
// MARK: - Trackers Managment
extension TrackerViewModel {
    
    // MARK: - Trackers Data Getter
    @inlinable
    var wholeTrackersCount: Int {
        model.wholeTrackersCount
    }
    @inline(__always)
    var numberOfSections: Int {
        model.numberOfSections
    }
    @inline(__always)
    func numberOfItemsInSection(_ section: Int) -> Int {
        model.numberOfItemsInSection(section)
    }
    @inline(__always)
    func tracker(at indexPath: IndexPath) -> TrackerModel? {
        model.tracker(at: indexPath)
    }
    @inline(__always)
    func trackerCountWithoutFilter(
        titleFilter: String?,
        date: Date
    ) -> Int {
        do {
            return try model.trackerCountWithoutFilter(
                titleFilter: titleFilter,
                date: date
            )
        } catch {
            onError?("Failed to get tracker count: \(error)")
            return 0
        }
    }
    func trackerEntity(by uuid: UUID) -> TrackerEntity? {
        do {
            return try model.trackerEntity(by: uuid)
        } catch {
            onError?("Failed to get tracker entity: \(error)")
            return nil
        }
    }
    @inline(__always)
    func sectionName(at index: Int) -> String? {
        model.sectionName(at: index)
    }
    func isTrackerPinned(uuid: UUID) -> Bool {
        #warning("TODO: implement this method")
        return false
    }
    
    
    // MARK: - Tracker Creation
    func addNewTracker(_ tracker: TrackerModel, to categoryName: String) {
        do {
            try model.addNewTracker(tracker, to: categoryName)
        } catch {
            onError?("Failed to add new tracker: \(error)")
        }
    }

    // MARK: - Tracker deletion
    func deleteTracker(at indexPath: IndexPath) {
        do {
            try model.deleteTracker(at: indexPath)
        } catch {
            onError?("Failed to delete tracker: \(error)")
        }
    }
    
    // MARK: - Tracker Edit
    func editTracker(new tracker: TrackerModel, newCategoryName: String) {
        do {
            try model.editTracker(new: tracker, newCategoryName: newCategoryName)
        } catch {
            onError?("Failed to edit tracker: \(error)")
        }
    }
    
    func pinTracker(indexPath: IndexPath) {
        do {
            try model.pinTracker(indexPath: indexPath)
        } catch {
            onError?("Failed to pin tracker: \(error)")
        }
    }
    
    func unpinTracker(indexPath: IndexPath) {
        do {
            try model.unpinTracker(indexPath: indexPath)
        } catch {
            onError?("Failed to unpin tracker: \(error)")
        }
    }
    
    // MARK: - Trackers Filter Update
    @inline(__always)
    func updateFilterPredicate(
        trackerTitleFilter: String?,
        onlyCompleted: Bool?,
        dateFilter: Date
    ) {
        do {
            try model.updatePredicate(
                titleFilter: trackerTitleFilter,
                onlyCompleted: onlyCompleted,
                date: dateFilter
            )
        } catch {
            onError?("Failed to update filter predicate: \(error)")
        }
    }
}
