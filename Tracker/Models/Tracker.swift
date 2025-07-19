import UIKit

struct Tracker: Identifiable, Hashable {
    let id: UUID
    let title: String
    let emoji: String
    let color: UIColor
    let schedule: [WeekdayOption]
}
