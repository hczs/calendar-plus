import Foundation

enum StatusBarTitleFormatter {
    static func title(for mode: StatusIconMode, on date: Date = Date(), calendar: Calendar = .current) -> String {
        switch mode {
        case .fixedIcon:
            return "📅"
        case .todayDate:
            return "\(calendar.component(.day, from: date))"
        }
    }
}
