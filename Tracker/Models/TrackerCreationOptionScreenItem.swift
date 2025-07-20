import UIKit

struct TrackerCreationOptionScreenItem {
    let name: Name
    let destinationController: UIViewController.Type
    
    enum Name: String {
        case category = "Категория"
        case schedule = "Расписание"
    }
}
