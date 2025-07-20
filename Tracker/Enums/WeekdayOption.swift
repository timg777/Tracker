enum WeekdayOption: Int8, CaseIterable {
    case monday = 0
    case tuesday = 1
    case wednesday = 2
    case thursday = 3
    case friday = 4
    case saturday = 5
    case sunday = 6
    
    func isEqual(to weekday: Int) -> Bool {
        switch self {
        case .monday:
            weekday == 2
        case .tuesday:
            weekday == 3
        case .wednesday:
            weekday == 4
        case .thursday:
            weekday == 5
        case .friday:
            weekday == 6
        case .saturday:
            weekday == 7
        case .sunday:
            weekday == 1
        }
    }
    
    var fullName: String {
        switch self {
        case .monday:
            return "Понедельник"
        case .tuesday:
            return "Вторник"
        case .wednesday:
            return "Среда"
        case .thursday:
            return "Четверг"
        case .friday:
            return "Пятница"
        case .saturday:
            return "Суббота"
        case .sunday:
            return "Воскресенье"
        }
    }
    
    var briefName: String {
        switch self {
        case .monday:
            return "Пн"
        case .tuesday:
            return "Вт"
        case .wednesday:
            return "Ср"
        case .thursday:
            return "Чт"
        case .friday:
            return "Пт"
        case .saturday:
            return "Сб"
        case .sunday:
            return "Вс"
        }
    }
}
