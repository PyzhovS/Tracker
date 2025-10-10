import Foundation

// MARK: - Localizable
enum Localizable {
    // MARK: - Base Translators
    // Base translator
    private static func tr(_ key: String, comment: String = "") -> String {
        NSLocalizedString(key, tableName: "Localizable", bundle: .main, value: "", comment: comment)
    }
    // Formatter for stringsdict and formatted strings
    private static func trf(_ key: String, _ args: CVarArg..., comment: String = "") -> String {
        let format = tr(key, comment: comment)
        return String(format: format, locale: Locale.current, arguments: args)
    }
    
    // MARK: - Common
    enum Common {
        static var done: String { tr("common.done", comment: "Action: Done") }
        static var cancel: String { tr("common.cancel", comment: "Action: Cancel") }
        static var ok: String { tr("common.ok", comment: "Action: OK") }
        static var errorGeneric: String { tr("common.errorGeneric", comment: "Generic error message") }
        static var delete: String { tr("common.delete", comment: "Action: Delete") }
    }
    
    // MARK: - Alerts
    enum Alerts {
        static var errorTitle: String { tr("alerts.errorTitle", comment: "Title for error alert") }
        static var deleteTitle: String { tr("alerts.deleteTitle") }
        static var deleteMessage: String { tr("alerts.deleteMessage") }
    }
    
    // MARK: - Errors
    enum Errors {
        static var categoryAlreadyExists: String { tr("errors.categoryAlreadyExists") }
        static var failedToSave: String { tr("errors.failedToSave") }
        static var failedToFetch: String { tr("errors.failedToFetch") }
        static var failedToDelete: String { tr("errors.failedToDelete") }
        static var failedToUpdate: String { tr("errors.failedToUpdate") }
        
    }
    
    // MARK: - Weekday
    enum Weekday {
        static var monday: String { tr("weekday.monday") }
        static var tuesday: String { tr("weekday.tuesday") }
        static var wednesday: String { tr("weekday.wednesday") }
        static var thursday: String { tr("weekday.thursday") }
        static var friday: String { tr("weekday.friday") }
        static var saturday: String { tr("weekday.saturday") }
        static var sunday: String { tr("weekday.sunday") }
    }
    
    // MARK: - WeekdayShort
    enum WeekdayShort {
        static var monday: String { tr("weekdayShort.monday") }
        static var tuesday: String { tr("weekdayShort.tuesday") }
        static var wednesday: String { tr("weekdayShort.wednesday") }
        static var thursday: String { tr("weekdayShort.thursday") }
        static var friday: String { tr("weekdayShort.friday") }
        static var saturday: String { tr("weekdayShort.saturday") }
        static var sunday: String { tr("weekdayShort.sunday") }
    }
    
    // MARK: - AddCategory
    enum AddCategory {
        static var title: String { tr("addCategory.title") }
        static var placeholder: String { tr("addCategory.placeholder") }
    }
    
    // MARK: - Schedule
    enum Schedule {
        static var title: String { tr("schedule.title") }
    }
    
    // MARK: - Category
    enum Category {
        static var title: String { tr("category.title") }
        static var placeholderText: String { tr("category.placeholderText") }
        static var addButton: String { tr("category.addButton") }
    }
    
    // MARK: - NewTracker
    enum NewTracker {
        static var title: String { tr("newTracker.title") }
        static var namePlaceholder: String { tr("newTracker.namePlaceholder") }
        static var emojiTitle: String { tr("newTracker.emojiTitle") }
        static var colorTitle: String { tr("newTracker.colorTitle") }
        static var create: String { tr("newTracker.create") }
        static var category: String { tr("newTracker.category") }
        static var schedule: String { tr("newTracker.schedule") }
        static var everyDay: String { tr("newTracker.everyDay") }
    }
    
    // MARK: - EditTracker
    // Экран редактирования
    enum EditTracker {
        static var title: String { tr("editTracker.title") } // "Редактирование привычки"
        static var save: String { tr("editTracker.save") }   // "Сохранить"
    }
    
    // MARK: - Onboarding
    enum Onboarding {
        static var actionButton: String { tr("onboarding.actionButton") }
        static var page1Title: String { tr("onboarding.page1.title") }
        static var page2Title: String { tr("onboarding.page2.title") }
    }
    
    // MARK: - Trackers
    enum Trackers {
        static var title: String { tr("trackers.title") }
        static var searchPlaceholder: String { tr("trackers.searchPlaceholder") }
        static var emptyTitle: String { tr("trackers.emptyTitle") }
    }
    
    // MARK: - Tabbar
    enum Tabbar {
        static var statistics: String { tr("statistics.tabbar") }
        static var trackers: String { tr("trackers.tabbar") }
    }
    
    // MARK: - Dates
    enum Dates {
        static func daysCount(_ count: Int) -> String {
            trf("dates.days_count", count, comment: "Pluralized number of days")
        }
    }
    
    // MARK: - ContextMenu
    enum ContextMenu {
        static var edit: String { tr("contextMenu.edit") }
        static var delete: String { tr("contextMenu.delete") }
    }
    
    // MARK: - Statistics
    enum Statistics {
        static var title: String { tr("statistics.title") }
        static var empty: String { tr("statistics.empty") }
        static var bestPeriod: String { tr("statistics.bestPeriod") }
        static var idealDays: String { tr("statistics.idealDays") }
        static var completedCount: String { tr("statistics.completedCount") }
        static var averageValue: String { tr("statistics.averageValue") }
    }
}
