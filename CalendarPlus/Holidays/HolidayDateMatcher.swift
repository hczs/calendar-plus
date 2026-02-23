import Foundation

struct HolidayDateMatcher {
    let calendar: Calendar

    init(timeZoneID: String = "Asia/Shanghai") {
        var cal = Calendar(identifier: .gregorian)
        cal.timeZone = TimeZone(identifier: timeZoneID) ?? .current
        self.calendar = cal
    }

    func matches(date: Date, holidayDateString: String) -> Bool {
        let parts = holidayDateString.split(separator: "-")
        guard parts.count == 3,
              let year = Int(parts[0]),
              let month = Int(parts[1]),
              let day = Int(parts[2])
        else {
            return false
        }

        let comps = calendar.dateComponents([.year, .month, .day], from: date)
        return comps.year == year && comps.month == month && comps.day == day
    }
}
