import Foundation
import UIKit

struct Tracker {
    let id: UUID
    let title: String
    let emoji: String
    let color: UIColor
    let schedule: [WeekDay]?
}

enum WeekDay: Int, CaseIterable, Codable {
    case monday = 2
    case tuesday = 3
    case wednesday = 4
    case thursday = 5
    case friday = 6
    case saturday = 7
    case sunday = 1
    var numberValue: Int {
        return self.rawValue
    }
    
    var displayName: String {
        switch self {
        case .monday: return Localizable.Weekday.monday
        case .tuesday: return Localizable.Weekday.tuesday
        case .wednesday: return Localizable.Weekday.wednesday
        case .thursday: return Localizable.Weekday.thursday
        case .friday: return Localizable.Weekday.friday
        case .saturday: return Localizable.Weekday.saturday
        case .sunday: return Localizable.Weekday.sunday
        }
    }
}

