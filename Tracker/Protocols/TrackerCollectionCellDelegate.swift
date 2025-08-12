import Foundation

protocol TrackerCollectionCellDelegate: AnyObject {
    func dateIsLessThanTodayDate() -> Bool
    func toggleTrackerRecord(
        for uuid: UUID,
        updateWith indexPath: IndexPath
    )
    func trackerRecordsCount(for uuid: UUID) -> Int
    func isTrackerCompletedToday(uuid: UUID) -> Bool
}
