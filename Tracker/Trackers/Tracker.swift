import Foundation
import UIKit

struct Tracker {
        let id: UUID
        let title: String
        let emoji: String
        let color: UIColor
        let schedule: [WeekDay]?
    }
    

enum WeekDay: Int, CaseIterable {
    case monday = 1
    case tuesday
    case wednesday
    case thursday
    case friday
    case saturday
    case sunday
}
