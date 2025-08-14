import Foundation

final class LocalizationManager {
        
    enum UIElement {
        var stringKey: String {
            switch self {
            case .shared(let element):
                element.rawValue
            case .onboarding(let element):
                element.rawValue
            case .trackerCollectionCell(let element):
                element.rawValue
            case .trackersViewController(let element):
                element.rawValue
            case .tabBar(let element):
                element.rawValue
            case .noContentPlaceholder(let element):
                element.rawValue
            case .category(let element):
                element.rawValue
            case .trackerCreation(let element):
                element.rawValue
            case .scheduleViewController(let element):
                element.rawValue
            case .schdule(let element):
                element.rawValue
            case .trackerOptions(let element):
                element.rawValue
            case .filter(let element):
                element.rawValue
            case .stats(let element):
                element.rawValue
            }
        }
        
        case onboarding(Onboarding)
        case trackerCollectionCell(TrackerCollectionCell)
        case trackersViewController(TrackersViewController)
        case tabBar(TabBar)
        case noContentPlaceholder(NoContentPlaceHolder)
        case category(Category)
        case trackerCreation(TrackerCreation)
        case trackerOptions(TrackerOption)
        case scheduleViewController(ScheduleViewController)
        case schdule(Schedule)
        case filter(Filter)
        case stats(Statistic)
        
        case shared(Shared)
        
        enum Shared: String {
            case unpin = "unpin"
            case remove = "delete"
            case cancel = "cancel"
            case pin = "pin"
            case edit = "edit"
            case save = "save"
            case create = "create"
            case symbolsCountRestriction = "symbolsCountRestriction"
        }
        
        enum TrackersViewController: String {
            case alertTitle = "trackerViewController_AlertTitle"
            case navigationTitle = "trackerViewController_navigationTitle"
            case filtersButton = "trackerViewController_filtersButton"
        }
        
        enum TrackerCollectionCell: String {
            case daysCheckedCount = "trackerDaysCheckedCount"
        }
        
        enum Onboarding: String {
            case aboutTrackerTitleText = "onboardingAboutTracker"
            case aboutWaterAndYYogaTitleText = "onboardingAboutWaterAndYoga"
            case skipButton = "onboardingSkipButton"
        }
        
        enum TabBar: String {
            case trackers = "tabBarTrackers"
            case stats = "tabBarStats"
        }
        
        enum NoContentPlaceHolder: String {
            case noSearchResults = "noContentPlaceHolder_noSearchResults"
            case noCategoriesInTrackersFound = "noContentPlaceHolder_noCategoriesInTrackersFound"
            case noCategoriesFound = "noContentPlaceHolder_noCategoriesFound"
            case noStatisticsFound = "noContentPlaceHolder_noStatisticsFound"
        }
        
        enum Category: String {
            case addCategoryButton = "category_addCategoryButton"
            case navigationTitle = "category_navigationTitle"
            case alert = "category_alert"
        }
        
        enum TrackerCreation: String {
            case navigationTitle = "trackerCreation_navigationTitle"
            case habitButton = "trackerCreation_habitButton"
            case irregularButton = "trackerCreation_irregularButton"
        }
        
        enum TrackerOption: String {
            case tableViewCategory = "trackerOption_tableViewCategory"
            case tableViewSchedule = "trackerOption_tableViewSchedule"
            
            case emojiSection = "trackerOption_emojiSection"
            case colorSection = "trackerOption_colorSection"
            
            case editNavigationTitle = "trackerOption_editNavigationTitle"
            case irregularNavigationTitle = "trackerOption_irregularNavigationTitle"
            case habitNavigationTitle = "trackerOption_habitNavigationTitle"
            
            case textFieldPlaceholder = "trackerOption_textFieldPlaceholder"
        }
        
        enum ScheduleViewController: String {
            case navigationTitle = "schduleViewController_navigationTitle"
            case confirmButton = "schduleViewController_confirmButton"
        }
        
        enum Schedule: String {
            case monday = "schedule_monday"
            case tuesday = "schedule_tuesday"
            case wednesday = "schedule_wednesday"
            case thursday = "schedule_thursday"
            case friday = "schedule_friday"
            case saturday = "schedule_saturday"
            case sunday = "schedule_sunday"
            
            case monday_brief = "schedule_monday_brief"
            case tuesday_brief = "schedule_tuesday_brief"
            case wednesday_brief = "schedule_wednesday_brief"
            case thursday_brief = "schedule_thursday_brief"
            case friday_brief = "schedule_friday_brief"
            case saturday_brief = "schedule_saturday_brief"
            case sunday_brief = "schedule_sunday_brief"
            
            case allDays = "schedule_allDays"
        }
        
        enum Filter: String {
            case allTracker = "filter_allTracker"
            case trackersForToday = "filter_trackersForToday"
            case completedTracker = "filter_completedTracker"
            case uncompletedTracker = "filter_uncompletedTracker"
            case navigationTitle = "filter_navigationTitle"
        }
        
        enum Statistic: String {
            case navigationTitle = "statistic_navigationTitle"
            case bestPeriod = "statistic_bestPeriod"
            case idealDays = "statistic_idealDays"
            case completedTrackers = "statistic_completedTrackers"
            case averageDays = "statistic_averageDays"
        }
    }
    
    static let shared = LocalizationManager()
    private init() {}
    
    func localizedString(
        for uiElement: UIElement? = nil,
        using concreteStringKey: String? = nil
    ) -> String {
        let strinKey: String
        if let uiElement {
            strinKey = uiElement.stringKey
        } else if let concreteStringKey {
            strinKey = concreteStringKey
        } else {
            strinKey = "No Localization"
        }
        return NSLocalizedString(
            strinKey,
            comment: "Text for localization"
        )
    }
    
//    %@ — для объектов (обычно для строк, но можно использовать и для других объектов, которые поддерживают протокол CustomStringConvertible);
//    %d — для целых чисел (Int);
//    %u — для беззнаковых целых чисел (UInt);
//    %f — для чисел с плавающей точкой (Float, Double); можно также указать количество знаков после десятичной точки (например, %.2f для двух знаков после точки).
    
}

