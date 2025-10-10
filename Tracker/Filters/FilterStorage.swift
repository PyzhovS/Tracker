import Foundation

struct FilterStorage {
    private let key = "Trackers.CurrentFilter"
    private let defaults = UserDefaults.standard
    
    var current: FilterType? {
        get {
            guard let raw = defaults.string(forKey: key) else { return nil }
            return FilterType(rawValue: raw)
        }
        set {
            if let value = newValue {
                defaults.set(value.rawValue, forKey: key)
            } else {
                defaults.removeObject(forKey: key)
            }
        }
    }
}
