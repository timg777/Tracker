enum Weekday: UInt8, CaseIterable {
    case monday = 2
    case tuesday = 3
    case wednesday = 4
    case thursday = 5
    case friday = 6
    case saturday = 7
    case sunday = 1
    
    var rawString: String {
        "\(self.rawValue)"
    }
    
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
