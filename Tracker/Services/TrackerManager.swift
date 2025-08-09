import UIKit

final class TrackerManager {
    static let shared = TrackerManager()
    private init() {}
    
    // MARK: - Internal Properties
    var weekdays: [(weekday: Weekday, isChoosen: Bool)] = [
        (weekday: .monday, isChoosen: false),
        (weekday: .tuesday, isChoosen: false),
        (weekday: .wednesday, isChoosen: false),
        (weekday: .thursday, isChoosen: false),
        (weekday: .friday, isChoosen: false),
        (weekday: .saturday, isChoosen: false),
        (weekday: .sunday, isChoosen: false)
    ]
    
    var categories: [TrackerCategory] = mockCategories
    var choosenCategory: String?
    
    func selectedOptions(for name: TrackerCreationOptionScreenItem.Name) -> String? {
        switch name {
        case .category:
            return choosenCategory
        case .schedule:
            let schedule = convertScheduleToString()
            return schedule.isEmpty ? nil : schedule
        }
    }
}

// MARK: - Extensions + Internal TrackerCreationManager Helpers
extension TrackerManager {
    func convertScheduleToString() -> String {
        guard weekdays.contains(where: { $0.isChoosen }) else { return "" }
        
        guard weekdays.filter({ $0.isChoosen }).count < 7 else {
            return "Каждый день"
        }
        let sortedWeekdays = weekdays.filter({ $0.isChoosen }).sorted(by: {$0.weekday.rawValue < $1.weekday.rawValue})
        var resultString: String = ""
        for (index, weekdayOption) in sortedWeekdays.enumerated() {
            resultString += "\(weekdayOption.weekday.briefName)" + (index != sortedWeekdays.count - 1 ? ", " : "")
        }
        return resultString
    }
    
    func createTracker(
        categoryTitle: String,
        tracker: TrackerModel
    ) {
        // MARK: - Мы допускаем одинаковые названия привычек, так как другие атрибуты включая индентификатор будут отличаться
        if let index = categories.firstIndex(where: {
            $0.title == categoryTitle
        }) {
            var trackers = categories[index].trackers
            trackers.append(tracker)
            let category = TrackerCategory(title: categoryTitle, trackers: trackers)
            categories[index] = category
        } else {
            let title = categoryTitle
            let newCategory = TrackerCategory(title: title, trackers: [tracker])
            categories.append(newCategory)
        }
        
        NotificationCenter.default.post(
            name: .categoriesDidChangedNotification,
            object: nil
        )
    }
}
