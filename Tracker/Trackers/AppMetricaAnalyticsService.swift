import Foundation
import AppMetricaCore

final class AppMetricaAnalyticsService: AnalyticsService {
    static let shared = AppMetricaAnalyticsService()
    
    private var isActivated = false
    private init() {}
    
    func activate(apiKey: String) {
        guard !isActivated else { return }
        if let configuration = AppMetricaConfiguration(apiKey: apiKey) {
            AppMetrica.activate(with: configuration)
            isActivated = true
            print("[Analytics] AppMetrica activated")
        } else {
            print("[Analytics] Failed to create AppMetrica configuration")
        }
    }
    
    func log(event: AnalyticsEvent, screen: AnalyticsScreen, item: AnalyticsItem?) {
        var params: [String: Any] = [
            "event": event.rawValue,
            "screen": screen.rawValue
        ]
        if let item = item {
            params["item"] = item.rawValue
        }
        
        if let item = item {
            print("[Analytics] ui_event event=\(event.rawValue) screen=\(screen.rawValue) item=\(item.rawValue)")
        } else {
            print("[Analytics] ui_event event=\(event.rawValue) screen=\(screen.rawValue)")
        }
        
        guard isActivated else { return }
        AppMetrica.reportEvent(name: "ui_event", parameters: params) { error in
            print("[Analytics] AppMetrica report error: \(error.localizedDescription)")
        }
    }
}
