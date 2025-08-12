import Foundation

final class UserDefaultsService {
    
    // MARK: - Internal Static Instance of UserDefaultsService [Singleton]
    static let shared = UserDefaultsService()
    
    // MARK: - Private Initialization
    private init() {}

    // MARK: - Internal Properties
    var isOnboardingCompleted: Bool {
        get { UserDefaults.standard.bool(forKey: "isOnboardingCompleted") }
        set { UserDefaults.standard.set(newValue, forKey: "isOnboardingCompleted") }
    }
    
}
