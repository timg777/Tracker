import Foundation

final class TrackerRecordViewModel {
    
    // MARK: - Private Constants
    private let model: TrackerRecordStore
    
    // MARK: - Internal Properties
    var trackerEntity: ((UUID) -> TrackerEntity?)?
    var onError: ((String) -> Void)?
    
    // MARK: - Initialization
    init(
        model: TrackerRecordStore
    ) {
        self.model = model
    }
}

// MARK: - Internal TrackerViewModel Extensions
// MARK: - CollectionView Helpers
// MARK: - TrackersRecords Managment
extension TrackerRecordViewModel {
    
    // MARK: - TrackerRecord Existence Toggling
    @inline(__always)
    func toggleTrackerRecord(record: TrackerRecord) {
        do {
            guard let trackerEntity = trackerEntity?(record.trackerId) else {
                throw CoreDataError.notFound(entityType: TrackerEntity.self, param: record.trackerId.uuidString)
            }
            try model.toggleTrackerRecord(record: record, with: trackerEntity)
        } catch {
            onError?("Failed to toggle tracker record: \(error)")
        }
    }
    
    // MARK: - TrackerRecord Data Getters
    @inline(__always)
    func countTrackerRecords(for uuid: UUID) -> Int {
        do {
            return try model.countTrackerRecords(for: uuid)
        } catch {
            onError?("Failed to count tracker records: \(error)")
            return 0
        }
    }
    @inline(__always)
    func isTrackerCompleteToday(record: TrackerRecord) -> Bool {
        do {
            return try model.isTrackerCompleteToday(record: record)
        } catch {
            onError?("Failed to check if tracker is complete today: \(error)")
            return false
        }
    }
}
