
import Foundation

enum AnalyticsEvent: String {
    case open
    case close
    case click
}

enum AnalyticsScreen: String {
    case main = "Main"
}

enum AnalyticsItem: String {
    case addTrack = "add_track"
    case track = "track"
    case filter = "filter"
    case edit = "edit"
    case delete = "delete"
}

protocol AnalyticsService: AnyObject {
    func activate(apiKey: String)
    func log(event: AnalyticsEvent, screen: AnalyticsScreen, item: AnalyticsItem?)
}

enum Analytics {
    static var shared: AnalyticsService = AppMetricaAnalyticsService.shared
}
