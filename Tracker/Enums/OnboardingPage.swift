import DeveloperToolsSupport

enum OnboardingPage: UInt8 {
    case first, second
    
    var title: String {
        switch self {
        case .first:
            "Отслеживайте только то, что хотите"
        case .second:
            "Даже если это не литры воды и йога"
        }
    }
    
    var backgroundImageReource: ImageResource {
        switch self {
        case .first:
            .onboardingBackgrounFirst
        case .second:
            .onboardingBackgrounSecond
        }
    }
}
