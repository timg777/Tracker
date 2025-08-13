import UIKit

struct TrackerCreationModel {
    let id: UUID?
    let title: String?
    let emoji: String?
    let color: UIColor?
    let categoryName: String?
    let schedule: [Weekday]?
    
    init(
        id: UUID? = nil,
        title: String? = nil,
        emoji: String? = nil,
        color: UIColor? = nil,
        categoryName: String? = nil,
        schedule: [Weekday]? = nil
    ) {
        self.id = id
        self.title = title
        self.emoji = emoji
        self.color = color
        self.categoryName = categoryName
        self.schedule = schedule
    }
}
