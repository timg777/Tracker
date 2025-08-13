import UIKit

enum OnboardingPage: UInt8 {
    case aboutTracker, aboutWaterAndYoga
    
    var title: String {
        switch self {
        case .aboutTracker:
            "Отслеживайте только то, что хотите"
        case .aboutWaterAndYoga:
            "Даже если это не литры воды и йога"
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
