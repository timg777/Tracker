import UIKit

struct TrackerCreationOptionScreenItem {
    let name: Name
    let destinationController: UIViewController.Type
    
    enum Name {
        case category
        case schedule
        
        var title: String {
            switch self {
            case .category:
                LocalizationManager.shared.localizedString(for: .trackerOptions(.tableViewCategory))
            case .schedule:
                LocalizationManager.shared.localizedString(for: .trackerOptions(.tableViewSchedule))
            }
        }
    }
}
