import AppKit

enum DayMarkerType {
    case none
    case holiday
    case makeupWorkday
}

struct CalendarTheme {
    let background: NSColor
    let cardBackground: NSColor
    let border: NSColor
    let headerText: NSColor
    let weekText: NSColor
    let primary: NSColor
    let dayText: NSColor
    let workdayMarker: NSColor
    let footerBackground: NSColor
    let footerText: NSColor
    let secondaryIcon: NSColor
    let todayDetailText: NSColor

    static func current(for appearance: NSAppearance?) -> CalendarTheme {
        let isDark = appearance?.bestMatch(from: [.darkAqua, .aqua]) == .darkAqua
        if isDark {
            return CalendarTheme(
                background: NSColor(calibratedRed: 0.11, green: 0.12, blue: 0.14, alpha: 1),
                cardBackground: NSColor(calibratedRed: 0.15, green: 0.16, blue: 0.19, alpha: 1),
                border: NSColor(calibratedWhite: 1, alpha: 0.09),
                headerText: NSColor(calibratedWhite: 0.93, alpha: 1),
                weekText: NSColor(calibratedRed: 0.56, green: 0.61, blue: 0.70, alpha: 1),
                primary: NSColor(calibratedRed: 0.93, green: 0.22, blue: 0.26, alpha: 1),
                dayText: NSColor(calibratedWhite: 0.84, alpha: 1),
                workdayMarker: NSColor(calibratedRed: 0.28, green: 0.55, blue: 0.92, alpha: 1),
                footerBackground: NSColor(calibratedWhite: 0.08, alpha: 0.55),
                footerText: NSColor(calibratedRed: 0.68, green: 0.72, blue: 0.80, alpha: 1),
                secondaryIcon: NSColor(calibratedRed: 0.54, green: 0.60, blue: 0.70, alpha: 1),
                todayDetailText: NSColor(calibratedWhite: 0.94, alpha: 0.9)
            )
        }
        return CalendarTheme(
            background: NSColor(calibratedRed: 0.90, green: 0.93, blue: 0.97, alpha: 1),
            cardBackground: NSColor(calibratedRed: 0.98, green: 0.99, blue: 1.00, alpha: 1),
            border: NSColor(calibratedRed: 0.76, green: 0.80, blue: 0.88, alpha: 0.5),
            headerText: NSColor(calibratedRed: 0.14, green: 0.19, blue: 0.29, alpha: 1),
            weekText: NSColor(calibratedRed: 0.44, green: 0.51, blue: 0.63, alpha: 1),
            primary: NSColor(calibratedRed: 0.94, green: 0.22, blue: 0.26, alpha: 1),
            dayText: NSColor(calibratedRed: 0.17, green: 0.22, blue: 0.32, alpha: 1),
            workdayMarker: NSColor(calibratedRed: 0.22, green: 0.52, blue: 0.93, alpha: 1),
            footerBackground: NSColor(calibratedRed: 0.93, green: 0.95, blue: 0.98, alpha: 1),
            footerText: NSColor(calibratedRed: 0.32, green: 0.39, blue: 0.49, alpha: 1),
            secondaryIcon: NSColor(calibratedRed: 0.36, green: 0.44, blue: 0.56, alpha: 1),
            todayDetailText: NSColor(calibratedWhite: 0.97, alpha: 0.92)
        )
    }
}
