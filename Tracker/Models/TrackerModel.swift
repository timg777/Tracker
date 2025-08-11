import UIKit

struct TrackerModel: Identifiable, Hashable {
    let id: UUID
    let title: String
    let emoji: String
    let color: UIColor
    let schedule: [Weekday]
}

// MARK: - Extensions + Internal TrackerModel from entity Initialization
extension TrackerModel {
    init?(entity: TrackerEntity) {
        let schedule = entity.schedule?.split(separator: " ").compactMap {
            if let rawValue = UInt8($0) {
                return Weekday(rawValue: rawValue)
            } else {
                return nil
            }
        }
        
        guard
            let schedule,
            let id = entity.trackerID,
            let title = entity.title,
            let emoji = entity.emoji,
            let hexColor = entity.hexColor,
            let color = UIColor(hex: hexColor)
        else {
            return nil
        }
        
        self.id = id
        self.title = title
        self.emoji = emoji
        self.color = color
        self.schedule = schedule
    }
}
