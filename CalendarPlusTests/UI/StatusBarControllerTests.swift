import XCTest
@testable import CalendarPlus

final class StatusBarTitleFormatterTests: XCTestCase {
    func test_status_bar_icon_uses_template_sf_symbol() {
        let image = AppBrandResources.statusBarIcon()
        XCTAssertNotNil(image)
        XCTAssertTrue(image?.isTemplate == true)
    }

    func test_fixed_icon_mode_uses_empty_title() {
        XCTAssertEqual(StatusBarTitleFormatter.title(for: .fixedIcon), "")
    }

    func test_today_date_mode_shows_day_number() {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone(identifier: "Asia/Shanghai")!
        let date = calendar.date(from: DateComponents(year: 2026, month: 5, day: 19))!
        XCTAssertEqual(StatusBarTitleFormatter.title(for: .todayDate, on: date, calendar: calendar), "19")
    }
}
