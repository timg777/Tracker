import Foundation

// MARK: - Extensions + Internal Notification.Name Custom Names
extension Notification.Name {
    static let scheduleDidChangedNotification: Notification.Name = .init(rawValue: "scheduleDidChangedNotification")
    static let categoryDidChangedNotification: Notification.Name = .init(rawValue: "categoryDidChangedNotification")
}
