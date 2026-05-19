import AppKit

enum DayMarkerType {
    case none
    case holiday
    case makeupWorkday
}

struct CalendarTheme {
    let background: NSColor
    let elevated: NSColor
    let divider: NSColor
    let headerText: NSColor
    let weekText: NSColor
    let primary: NSColor
    let dayText: NSColor
    let workdayMarker: NSColor
    let holidayTint: NSColor
    let workdayTint: NSColor
    let secondaryIcon: NSColor
    let todayDetailText: NSColor

    var cardBackground: NSColor { elevated }
    var border: NSColor { divider }
    var footerBackground: NSColor { elevated }
    var footerText: NSColor { weekText }

    static func current(for appearance: NSAppearance?) -> CalendarTheme {
        let isDark = appearance?.bestMatch(from: [.darkAqua, .aqua]) == .darkAqua
        if isDark {
            return CalendarTheme(
                background: NSColor(calibratedRed: 0.11, green: 0.11, blue: 0.10, alpha: 1),
                elevated: NSColor(calibratedRed: 0.15, green: 0.14, blue: 0.13, alpha: 1),
                divider: NSColor(calibratedRed: 0.24, green: 0.23, blue: 0.21, alpha: 1),
                headerText: NSColor(calibratedRed: 0.95, green: 0.93, blue: 0.90, alpha: 1),
                weekText: NSColor(calibratedRed: 0.61, green: 0.58, blue: 0.55, alpha: 1),
                primary: NSColor(calibratedRed: 0.88, green: 0.38, blue: 0.38, alpha: 1),
                dayText: NSColor(calibratedRed: 0.90, green: 0.88, blue: 0.85, alpha: 1),
                workdayMarker: NSColor(calibratedRed: 0.45, green: 0.62, blue: 0.88, alpha: 1),
                holidayTint: NSColor(calibratedRed: 0.22, green: 0.14, blue: 0.14, alpha: 1),
                workdayTint: NSColor(calibratedRed: 0.12, green: 0.16, blue: 0.22, alpha: 1),
                secondaryIcon: NSColor(calibratedRed: 0.55, green: 0.52, blue: 0.49, alpha: 1),
                todayDetailText: NSColor(calibratedRed: 0.96, green: 0.94, blue: 0.92, alpha: 1)
            )
        }
        return CalendarTheme(
            background: NSColor(calibratedRed: 0.965, green: 0.957, blue: 0.941, alpha: 1),
            elevated: NSColor(calibratedRed: 0.992, green: 0.988, blue: 0.980, alpha: 1),
            divider: NSColor(calibratedRed: 0.898, green: 0.878, blue: 0.847, alpha: 1),
            headerText: NSColor(calibratedRed: 0.173, green: 0.157, blue: 0.141, alpha: 1),
            weekText: NSColor(calibratedRed: 0.420, green: 0.396, blue: 0.376, alpha: 1),
            primary: NSColor(calibratedRed: 0.831, green: 0.294, blue: 0.310, alpha: 1),
            dayText: NSColor(calibratedRed: 0.173, green: 0.157, blue: 0.141, alpha: 1),
            workdayMarker: NSColor(calibratedRed: 0.290, green: 0.498, blue: 0.831, alpha: 1),
            holidayTint: NSColor(calibratedRed: 0.953, green: 0.894, blue: 0.894, alpha: 1),
            workdayTint: NSColor(calibratedRed: 0.894, green: 0.925, blue: 0.973, alpha: 1),
            secondaryIcon: NSColor(calibratedRed: 0.420, green: 0.396, blue: 0.376, alpha: 1),
            todayDetailText: NSColor(calibratedRed: 0.980, green: 0.973, blue: 0.965, alpha: 1)
        )
    }
}
