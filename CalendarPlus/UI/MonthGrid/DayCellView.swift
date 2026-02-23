import AppKit

struct DayCellViewModel {
    let day: Int
    let isToday: Bool
    let isSelected: Bool
    let isHoliday: Bool

    var badgeText: String? {
        isHoliday ? "假" : nil
    }
}

final class DayCellView: NSView {}
