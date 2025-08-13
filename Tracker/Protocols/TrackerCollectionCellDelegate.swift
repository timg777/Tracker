import Foundation

protocol TrackerCollectionCellDelegate: AnyObject {
    func dateIsLessThanTodayDate() -> Bool
    func toggleTrackerRecord(
        for uuid: UUID,
        updateWith indexPath: IndexPath
    )
    func trackerRecordsCount(for uuid: UUID) -> Int
    func isTrackerCompletedToday(uuid: UUID) -> Bool
    func isTrackerPinned(uuid: UUID) -> Bool
    
    func pinTracker(at indexPath: IndexPath?)
    func unpinTracker(at indexPath: IndexPath?)
    func editTracker(at indexPath: IndexPath?)
    func tryDeleteTracker(at indexPath: IndexPath?)
}
