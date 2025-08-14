import YandexMobileMetrica

final class YMMYYandexMetricaReportManager {
    
    enum YMMYYandexMetricaReportEvent {
        case open, close, click
    }
    
    enum YMMYYandexMetricaReportItem {
        case add_track, tracker, filter, edit, delete, context
    }
    
    // MARK: - Internal Static [Singleton] intance initialization
    static let shared = YMMYYandexMetricaReportManager()
    
    // MARK: - Private Initilization
    private init() {}
    
}

// MARK: - Extensions + Interanl YMMYYandexMetricaReportManager Methods
extension YMMYYandexMetricaReportManager {
    func sendReport(
        reportTitle: String,
        errorString: String
    ) {
        YMMYandexMetrica.reportEvent(
            reportTitle,
            parameters: ["error": errorString]
        ) { error in
            print("REPORT EVENT ERROR: \(error)")
        }
    }
    
    func sendActionReport(
        reportTitle: String,
        event: YMMYYandexMetricaReportEvent,
        screenName: String,
        item: YMMYYandexMetricaReportItem?
    ) {
        var parameters: [String: Any] = [
            "event": event,
            "screen": screenName,
        ]
        
        if let item {
            parameters["item"] = item
        }
        
        YMMYandexMetrica.reportEvent(
            reportTitle,
            parameters: parameters
        ) { error in
            print("REPORT EVENT ERROR: \(error)")
        }
    }
}
