import Foundation

enum FilterType: String {
    case all
    case today
    case completed
    case incompleted
    
    var isActive: Bool {
        switch self {
        case .completed, .incompleted: return true
        case .all, .today: return false
        }
    }
}
