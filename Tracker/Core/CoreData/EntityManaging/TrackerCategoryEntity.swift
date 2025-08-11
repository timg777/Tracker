import Foundation

@objc(TrackerCategoryEntity)
extension TrackerCategoryEntity {
    @nonobjc
    func update(with name: String) {
        self.name = name
    }
}
