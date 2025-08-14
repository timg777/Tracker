enum StatisticCellType: CaseIterable {
    case bestPeriod, idealDays, completedTrackers, averageDays
    
    var title: String {
        switch self {
        case .bestPeriod:
            LocalizationManager.shared.localizedString(for: .stats(.bestPeriod))
        case .idealDays:
            LocalizationManager.shared.localizedString(for: .stats(.idealDays))
        case .completedTrackers:
            LocalizationManager.shared.localizedString(for: .stats(.completedTrackers))
        case .averageDays:
            LocalizationManager.shared.localizedString(for: .stats(.averageDays))
        @unknown default:
            "No localization"
        }
    }
    
    var value: Int {
        switch self {
        case .bestPeriod:
            StatisticService.shared.bestPeriod
        case .idealDays:
            StatisticService.shared.idealDays
        case .completedTrackers:
            StatisticService.shared.completedTrackers
        case .averageDays:
            StatisticService.shared.averageDays
        @unknown default:
            0
        }
    }
}
