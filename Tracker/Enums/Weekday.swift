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
            LocalizationManager.shared.localizedString(for: .schdule(.monday))
        case .tuesday:
            LocalizationManager.shared.localizedString(for: .schdule(.tuesday))
        case .wednesday:
            LocalizationManager.shared.localizedString(for: .schdule(.wednesday))
        case .thursday:
            LocalizationManager.shared.localizedString(for: .schdule(.thursday))
        case .friday:
            LocalizationManager.shared.localizedString(for: .schdule(.friday))
        case .saturday:
            LocalizationManager.shared.localizedString(for: .schdule(.saturday))
        case .sunday:
            LocalizationManager.shared.localizedString(for: .schdule(.sunday))
        }
    }
    
    var briefName: String {
        switch self {
        case .monday:
            LocalizationManager.shared.localizedString(for: .schdule(.monday_brief))
        case .tuesday:
            LocalizationManager.shared.localizedString(for: .schdule(.tuesday_brief))
        case .wednesday:
            LocalizationManager.shared.localizedString(for: .schdule(.wednesday_brief))
        case .thursday:
            LocalizationManager.shared.localizedString(for: .schdule(.thursday_brief))
        case .friday:
            LocalizationManager.shared.localizedString(for: .schdule(.friday_brief))
        case .saturday:
            LocalizationManager.shared.localizedString(for: .schdule(.saturday_brief))
        case .sunday:
            LocalizationManager.shared.localizedString(for: .schdule(.sunday_brief))
        }
    }
}
