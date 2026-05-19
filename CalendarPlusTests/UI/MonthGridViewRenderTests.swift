import XCTest
@testable import CalendarPlus

final class MonthGridViewRenderTests: XCTestCase {
    private func currentMonthDay(matching weekday: Int) -> Int {
        var cal = Calendar(identifier: .gregorian)
        cal.firstWeekday = 2
        let now = Date()
        let comps = cal.dateComponents([.year, .month], from: now)
        let monthStart = cal.date(from: comps)!
        let dayCount = cal.range(of: .day, in: .month, for: monthStart)!.count
        for day in 1...dayCount {
            let d = cal.date(from: DateComponents(year: comps.year, month: comps.month, day: day))!
            if cal.component(.weekday, from: d) == weekday { return day }
        }
        return 1
    }

    private func assertColorClose(_ lhs: NSColor?, _ rhs: NSColor?, file: StaticString = #filePath, line: UInt = #line) {
        guard
            let lhs = lhs?.usingColorSpace(.sRGB),
            let rhs = rhs?.usingColorSpace(.sRGB)
        else {
            XCTFail("颜色为空或无法转换到 sRGB", file: file, line: line)
            return
        }

        XCTAssertEqual(lhs.redComponent, rhs.redComponent, accuracy: 0.01, file: file, line: line)
        XCTAssertEqual(lhs.greenComponent, rhs.greenComponent, accuracy: 0.01, file: file, line: line)
        XCTAssertEqual(lhs.blueComponent, rhs.blueComponent, accuracy: 0.01, file: file, line: line)
        XCTAssertEqual(lhs.alphaComponent, rhs.alphaComponent, accuracy: 0.01, file: file, line: line)
    }

    @MainActor
    func test_month_grid_creates_day_labels_for_current_month() {
        let sut = MonthGridView(frame: NSRect(x: 0, y: 0, width: 320, height: 380))
        sut.layoutSubtreeIfNeeded()

        let daysInMonth = Calendar.current.range(of: .day, in: .month, for: Date())!.count
        XCTAssertEqual(sut.renderedDayCountForTest, daysInMonth)
    }

    @MainActor
    func test_weekend_headers_have_special_colors() {
        let sut = MonthGridView(frame: NSRect(x: 0, y: 0, width: 320, height: 380))
        sut.layoutSubtreeIfNeeded()

        let saturday = sut.weekdayHeaderColorForTest(column: 5)
        let sunday = sut.weekdayHeaderColorForTest(column: 6)
        let friday = sut.weekdayHeaderColorForTest(column: 4)
        XCTAssertEqual(saturday, sunday)
        XCTAssertNotEqual(saturday, friday)
    }

    @MainActor
    func test_holiday_day_shows_badge_text() {
        let sut = MonthGridView(frame: NSRect(x: 0, y: 0, width: 320, height: 380))
        let comps = Calendar.current.dateComponents([.year, .month], from: Date())
        let dateString = String(format: "%04d-%02d-01", comps.year ?? 2026, comps.month ?? 1)
        sut.applyHolidayRecordsForTest([HolidayRecord(date: dateString, isHoliday: true, name: "测试假期")])
        sut.layoutSubtreeIfNeeded()

        XCTAssertTrue(sut.dayLabelTextForTest(day: 1).contains("[H]"))
        XCTAssertEqual(sut.cornerTagTextForTest(day: 1), "休")
    }

    @MainActor
    func test_each_day_shows_lunar_text_under_gregorian_day() {
        let sut = MonthGridView(frame: NSRect(x: 0, y: 0, width: 320, height: 420))
        let date = CalendarGregorian.shanghai.date(from: DateComponents(year: 2026, month: 3, day: 10))!
        sut.setDisplayedMonthForTest(date)
        sut.layoutSubtreeIfNeeded()

        XCTAssertFalse(sut.lunarTextForTest(day: 10).isEmpty)
    }

    @MainActor
    func test_festival_day_hides_lunar_text() {
        let sut = MonthGridView(frame: NSRect(x: 0, y: 0, width: 360, height: 560))
        let date = Calendar(identifier: .gregorian).date(from: DateComponents(year: 2026, month: 5, day: 1))!
        sut.setDisplayedMonthForTest(date)
        sut.layoutSubtreeIfNeeded()

        XCTAssertEqual(sut.festivalTextForTest(day: 1), "劳动节")
        XCTAssertTrue(sut.lunarTextForTest(day: 1).isEmpty)
    }

    @MainActor
    func test_makeup_workday_shows_blue_dot_marker() {
        let sut = MonthGridView(frame: NSRect(x: 0, y: 0, width: 320, height: 380))
        let comps = Calendar.current.dateComponents([.year, .month], from: Date())
        let saturdayDay = currentMonthDay(matching: 7)
        let dateString = String(format: "%04d-%02d-%02d", comps.year ?? 2026, comps.month ?? 1, saturdayDay)
        sut.applyHolidayRecordsForTest([HolidayRecord(date: dateString, isHoliday: false, name: "补班")])
        sut.layoutSubtreeIfNeeded()

        XCTAssertTrue(sut.dayLabelTextForTest(day: saturdayDay).contains("[W]"))
        XCTAssertEqual(sut.cornerTagTextForTest(day: saturdayDay), "班")
    }

    @MainActor
    func test_makeup_workday_on_weekday_hides_blue_dot() {
        let sut = MonthGridView(frame: NSRect(x: 0, y: 0, width: 320, height: 380))
        let comps = Calendar.current.dateComponents([.year, .month], from: Date())
        let tuesdayDay = currentMonthDay(matching: 3)
        let dateString = String(format: "%04d-%02d-%02d", comps.year ?? 2026, comps.month ?? 1, tuesdayDay)
        sut.applyHolidayRecordsForTest([HolidayRecord(date: dateString, isHoliday: false, name: "补班")])
        sut.layoutSubtreeIfNeeded()

        XCTAssertFalse(sut.dayLabelTextForTest(day: tuesdayDay).contains("[W]"))
        XCTAssertTrue(sut.cornerTagTextForTest(day: tuesdayDay).isEmpty)
    }

    @MainActor
    func test_theme_switch_recolors_existing_day_numbers() {
        let sut = MonthGridView(frame: NSRect(x: 0, y: 0, width: 420, height: 520))
        let weekdayDay = currentMonthDay(matching: 3)

        sut.appearance = NSAppearance(named: .darkAqua)
        sut.setDisplayedMonthForTest(Date())
        sut.layoutSubtreeIfNeeded()

        let darkColor = sut.dayNumberColorForTest(day: weekdayDay)
        let expectedDark = CalendarTheme.current(for: NSAppearance(named: .darkAqua)).dayText
        assertColorClose(darkColor, expectedDark)

        sut.appearance = NSAppearance(named: .aqua)
        sut.viewDidChangeEffectiveAppearance()
        sut.layoutSubtreeIfNeeded()

        let lightColor = sut.dayNumberColorForTest(day: weekdayDay)
        let expectedLight = CalendarTheme.current(for: NSAppearance(named: .aqua)).dayText
        assertColorClose(lightColor, expectedLight)
    }
}
