import UIKit

final class TrackerCreationViewModel {
    
    // MARK: - Private Constants
    private var model: TrackerCreationModel
    
    // MARK: - Internal Properties
    var trackerModel: (TrackerModel, String)? {
        guard
            let title = model.title,
            let emoji = model.emoji,
            let color = model.color,
            let schedule = model.schedule
        else { return nil }
        
        return (
            .init(
                id: model.id ?? .init(),
                title: title,
                emoji: emoji,
                color: color,
                schedule: schedule
            ),
            model.categoryName ?? GlobalConstants.defaultCategoryName
        )
    }
    
    // MARK: - Initialization
    init(model: TrackerCreationModel = .init()) {
        self.model = model
    }
    
    var hasAtLeastOneDaySelected: Bool {
        !(weekdays?.isEmpty ?? true)
    }
    var categoryName: String? {
        model.categoryName
    }
    var weekdays: [Weekday]? {
        model.schedule
    }
    var title: String? {
        model.title
    }
    var emoji: String? {
        model.emoji
    }
    var color: UIColor? {
        model.color
    }
}

extension TrackerCreationViewModel {
    func convertScheduleToString() -> String {
        guard
            let schedule = model.schedule,
            !schedule.isEmpty
        else { return "" }

        guard schedule.count < 7 else {
            return "Каждый день"
        }
        let sortedWeekdays = schedule.sorted(by: {$0.rawValue < $1.rawValue})
        var resultString: String = ""
        for (index, weekday) in sortedWeekdays.enumerated() {
            resultString += "\(weekday.briefName)" + (index != sortedWeekdays.count - 1 ? ", " : "")
        }
        
        return resultString
    }
    
    func selectedOptions(for name: TrackerCreationOptionScreenItem.Name) -> String? {
        switch name {
        case .category:
            return model.categoryName
        case .schedule:
            let schedule = convertScheduleToString()
            return schedule.isEmpty ? nil : schedule
        }
    }
}

// MARK: - Extensions + Internal TrackerCreationViewModel Data Managing
extension TrackerCreationViewModel {
    func setSchedule(_ schedule: [Weekday]) {
        model = TrackerCreationModel(
            id: model.id,
            title: model.title,
            emoji: model.emoji,
            color: model.color,
            categoryName: model.categoryName,
            schedule: schedule
        )
    }
    
    func setTitle(_ title: String) {
        model = TrackerCreationModel(
            id: model.id,
            title: title,
            emoji: model.emoji,
            color: model.color,
            categoryName: model.categoryName,
            schedule: model.schedule
        )
    }
    
    func setEmoji(_ emoji: String) {
        model = TrackerCreationModel(
            id: model.id,
            title: model.title,
            emoji: emoji,
            color: model.color,
            categoryName: model.categoryName,
            schedule: model.schedule
        )
    }
    
    func setColor(_ color: UIColor) {
        model = TrackerCreationModel(
            id: model.id,
            title: model.title,
            emoji: model.emoji,
            color: color,
            categoryName: model.categoryName,
            schedule: model.schedule
        )
    }
    
    func setCategoryName(_ categoryName: String?) {
        model = TrackerCreationModel(
            id: model.id,
            title: model.title,
            emoji: model.emoji,
            color: model.color,
            categoryName: categoryName,
            schedule: model.schedule
        )
    }
}
