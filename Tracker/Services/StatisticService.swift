import Combine

final class StatisticService {
    
    // MARK: - Internal Static Instance of UserDefaultsService [Singleton]
    static let shared = StatisticService()
    
    // MARK: - Private Initialization
    private init() {
        
    }
    
    var oneAtLeastExists: Bool {
        bestPeriod > 0 || idealDays > 0 || averageDays > 0 || completedTrackers > 0
    }
    
    var didChanged: (() -> Void)?
    
    // MARK: - «лучший период» — максимальное количество дней без перерыва по всем трекерам
    var bestPeriod: Int {
        get {
            UserDefaultsService.shared.storage.integer(forKey: "bestPeriod")
        }
        set {
            UserDefaultsService.shared.storage.set(newValue, forKey: "bestPeriod")
        }
    }
    
    // MARK: - «идеальные дни» — когда были выполнены все запланированные привычки
    var idealDays: Int {
        get {
            UserDefaultsService.shared.storage.integer(forKey: "idealDays")
        }
        set {
            UserDefaultsService.shared.storage.set(newValue, forKey: "idealDays")
        }
    }
    
    // MARK: - «среднее значение» — среднее количество привычек, выполненных за 1 день
    var averageDays: Int {
        get {
            UserDefaultsService.shared.storage.integer(forKey: "averageDays")
        }
        set {
            UserDefaultsService.shared.storage.set(newValue, forKey: "averageDays")
        }
    }
    
    // MARK: - «трекеров завершено» — общее количество завершенных трекеров
    var completedTrackers: Int {
        get {
            UserDefaultsService.shared.storage.integer(forKey: "completedTrackers")
        }
        set {
            UserDefaultsService.shared.storage.set(newValue, forKey: "completedTrackers")
        }
    }
}
