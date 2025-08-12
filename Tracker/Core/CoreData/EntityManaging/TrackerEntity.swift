import Foundation

// MARK: - Extensions + Internal TrackerEntity Updater
@objc(TrackerEntity)
extension TrackerEntity {
    @nonobjc
    func update(with model: TrackerModel) {
        self.trackerID = model.id
        self.title = model.title
        self.emoji = model.emoji
        self.hexColor = model.color.toHexString()
        if model.schedule.isEmpty {
            self.schedule = ""
        } else {
            self.schedule = model.schedule.map({ $0.rawString }).joined(separator: " ")
        }
    }
}
