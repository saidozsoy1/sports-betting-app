import Foundation

enum OddType: String {
    case home = "MS1"
    case away = "MS2"
    case draw = "MS0"
}

protocol EventCellDelegate: AnyObject {
    func didSelectOdd(for event: Event, oddType: OddType, selectedOdd: Double)
} 
