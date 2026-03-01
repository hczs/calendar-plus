import XCTest
@testable import CalendarPlus

final class HolidayDateMatcherTests: XCTestCase {
    func test_holiday_match_uses_asia_shanghai_calendar_day() {
        let matcher = HolidayDateMatcher(timeZoneID: "Asia/Shanghai")
        let date = ISO8601DateFormatter().date(from: "2026-02-16T16:30:00Z")!
        XCTAssertTrue(matcher.matches(date: date, holidayDateString: "2026-02-17"))
    }
}
