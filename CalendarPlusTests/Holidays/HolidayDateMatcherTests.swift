import XCTest
@testable import CalendarPlus

final class HolidayDateMatcherTests: XCTestCase {
    func test_holiday_match_uses_asia_shanghai_calendar_day() {
        let matcher = HolidayDateMatcher(timeZoneID: "Asia/Shanghai")
        let date = ISO8601DateFormatter().date(from: "2026-02-16T16:30:00Z")!
        XCTAssertTrue(matcher.matches(date: date, holidayDateString: "2026-02-17"))
    }

    func test_matching_record_returns_holiday_for_same_calendar_day() {
        let matcher = HolidayDateMatcher(timeZoneID: "Asia/Shanghai")
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone(identifier: "Asia/Shanghai")!
        let date = calendar.date(from: DateComponents(year: 2026, month: 2, day: 17, hour: 12))!
        let records = [HolidayRecord(date: "2026-02-17", isHoliday: true, name: "春节")]

        XCTAssertEqual(matcher.matchingRecord(for: date, in: records)?.name, "春节")
    }
}
