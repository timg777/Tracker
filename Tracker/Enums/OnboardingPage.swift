import UIKit

enum OnboardingPage: UInt8 {
    case aboutTracker, aboutWaterAndYoga
    
    var title: String {
        switch self {
        case .aboutTracker:
            LocalizationManager.shared.localizedString(for: .onboarding(.aboutTrackerTitleText))
        case .aboutWaterAndYoga:
            LocalizationManager.shared.localizedString(for: .onboarding(.aboutWaterAndYYogaTitleText))
        }
    }
    
    var backgroundImageReource: ImageResource {
        switch self {
        case .aboutTracker:
            .onboardingBackgrounFirst
        case .aboutWaterAndYoga:
            .onboardingBackgrounSecond
        }
    }
}
