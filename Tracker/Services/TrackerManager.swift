final class TrackerManager {
    static let shared = TrackerManager()
    private init() {}
    
    // MARK: - Internal Properties
    var weekdays: [(weekday: WeekdayOption, isChoosen: Bool)] = [
        (weekday: .monday, isChoosen: false),
        (weekday: .tuesday, isChoosen: false),
        (weekday: .wednesday, isChoosen: false),
        (weekday: .thursday, isChoosen: false),
        (weekday: .friday, isChoosen: false),
        (weekday: .saturday, isChoosen: false),
        (weekday: .sunday, isChoosen: false)
    ]
    
    var categories: [TrackerCategory] = []
    var choosenCategory: String?
    var categoriesDidChanged: (() -> Void)?
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
        tracker: Tracker
    ) {
        guard let category = categories.first(where: { $0.title == categoryTitle }) else { return }
        let newCategory = TrackerCategory(title: categoryTitle, trackers: category.trackers + [tracker])
        categories.removeAll(where: { $0.title == categoryTitle })
        categories.append(newCategory)
        categories.sort { $0.title < $1.title }
        categoriesDidChanged?()
    }
}
