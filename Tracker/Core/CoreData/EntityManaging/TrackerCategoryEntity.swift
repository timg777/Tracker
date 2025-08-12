import Foundation

// MARK: - Extensions + Internal TrackerCategoryEntity Updater
@objc(TrackerCategoryEntity)
extension TrackerCategoryEntity {
    @nonobjc
    func update(with name: String) {
        self.name = name
    }
}
