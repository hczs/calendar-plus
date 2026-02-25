import Foundation

struct CalendarAnnotations {
    private static let lunarMonthNames = ["正月", "二月", "三月", "四月", "五月", "六月", "七月", "八月", "九月", "十月", "冬月", "腊月"]
    private static let lunarDayNames = [
        "初一", "初二", "初三", "初四", "初五", "初六", "初七", "初八", "初九", "初十",
        "十一", "十二", "十三", "十四", "十五", "十六", "十七", "十八", "十九", "二十",
        "廿一", "廿二", "廿三", "廿四", "廿五", "廿六", "廿七", "廿八", "廿九", "三十"
    ]

    static func lunarText(for date: Date) -> String {
        let lunarCalendar = Calendar(identifier: .chinese)
        let comps = lunarCalendar.dateComponents([.month, .day], from: date)
        guard let month = comps.month, let day = comps.day,
              (1...12).contains(month), (1...30).contains(day)
        else {
            return ""
        }

        if day == 1 {
            return lunarMonthNames[month - 1]
        }
        return lunarDayNames[day - 1]
    }

    static func festivalText(for date: Date) -> String? {
        let festivals = festivalTexts(for: date)
        guard !festivals.isEmpty else { return nil }
        return festivals.joined(separator: "·")
    }

    static func festivalTexts(for date: Date) -> [String] {
        let gregorian = Calendar(identifier: .gregorian)
        let g = gregorian.dateComponents([.year, .month, .day, .weekday, .weekOfMonth], from: date)
        var result: [String] = []

        if g.month == 1 && g.day == 1 {
            result.append("元旦")
        }

        if g.month == 10 && g.day == 1 {
            result.append("国庆节")
        }

        if g.month == 5 && g.day == 1 {
            result.append("劳动节")
        }

        if g.month == 4, let year = g.year, g.day == qingmingDay(of: year) {
            result.append("清明节")
        }

        if g.month == 11, g.weekday == 5, g.weekOfMonth == 4 {
            result.append("感恩节")
        }

        if g.month == 2 && g.day == 14 {
            result.append("情人节")
        }

        if g.month == 3 && g.day == 8 {
            result.append("妇女节")
        }

        if g.month == 4 && g.day == 1 {
            result.append("愚人节")
        }

        if g.month == 6 && g.day == 1 {
            result.append("儿童节")
        }

        if g.month == 10 && g.day == 31 {
            result.append("万圣节")
        }

        if g.month == 12 && g.day == 25 {
            result.append("圣诞节")
        }

        let lunar = Calendar(identifier: .chinese)
        let l = lunar.dateComponents([.month, .day, .isLeapMonth], from: date)
        if l.isLeapMonth != true, l.month == 1, l.day == 1 {
            result.append("春节")
        }
        if l.isLeapMonth != true, l.month == 1, l.day == 15 {
            result.append("元宵节")
        }
        if l.isLeapMonth != true, l.month == 5, l.day == 5 {
            result.append("端午节")
        }
        if l.isLeapMonth != true, l.month == 8, l.day == 15 {
            result.append("中秋节")
        }

        return result
    }

    private static func qingmingDay(of year: Int) -> Int {
        // Valid for 2000-2099; this project currently targets modern years.
        let y = year - 2000
        return Int(Double(y) * 0.2422 + 4.81) - y / 4
    }
}
