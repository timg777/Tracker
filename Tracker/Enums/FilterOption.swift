enum FilterOption: CaseIterable {
    case allTrackers, trackersForToday, completedTrackers, uncompletedTrackers
    
    var title: String {
        switch self {
        case .allTrackers:
            LocalizationManager.shared.localizedString(for: .filter(.allTracker))
        case .trackersForToday:
            LocalizationManager.shared.localizedString(for: .filter(.trackersForToday))
        case .completedTrackers:
            LocalizationManager.shared.localizedString(for: .filter(.completedTracker))
        case .uncompletedTrackers:
            LocalizationManager.shared.localizedString(for: .filter(.uncompletedTracker))
        @unknown default:
            "No localizable string"
        }
    }
}
