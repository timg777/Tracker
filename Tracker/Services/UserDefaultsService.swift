import Foundation

final class UserDefaultsService {
    
    // MARK: - Internal Static Instance of UserDefaultsService [Singleton]
    static let shared = UserDefaultsService()
    let storage = UserDefaults.standard
    
    // MARK: - Private Initialization
    private init() {}

    // MARK: - Internal Properties
    var isOnboardingCompleted: Bool {
        get { storage.bool(forKey: "isOnboardingCompleted") }
        set { storage.set(newValue, forKey: "isOnboardingCompleted") }
    }
    
}
