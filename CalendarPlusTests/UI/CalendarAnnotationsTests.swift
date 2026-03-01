import XCTest
@testable import CalendarPlus

final class CalendarAnnotationsTests: XCTestCase {
    func test_lunar_text_is_not_empty_for_regular_day() {
        let date = Calendar(identifier: .gregorian).date(from: DateComponents(year: 2026, month: 2, day: 18))!
        XCTAssertFalse(CalendarAnnotations.lunarText(for: date).isEmpty)
    }

    func test_festival_detects_labor_day() {
        let date = Calendar(identifier: .gregorian).date(from: DateComponents(year: 2026, month: 5, day: 1))!
        XCTAssertEqual(CalendarAnnotations.festivalText(for: date), "劳动节")
    }

    func test_festival_detects_new_year() {
        let date = Calendar(identifier: .gregorian).date(from: DateComponents(year: 2026, month: 1, day: 1))!
        XCTAssertEqual(CalendarAnnotations.festivalText(for: date), "元旦")
    }

    func test_festival_detects_national_day() {
        let date = Calendar(identifier: .gregorian).date(from: DateComponents(year: 2026, month: 10, day: 1))!
        XCTAssertEqual(CalendarAnnotations.festivalText(for: date), "国庆节")
    }

    func test_festival_detects_qingming() {
        let date = Calendar(identifier: .gregorian).date(from: DateComponents(year: 2026, month: 4, day: 5))!
        XCTAssertEqual(CalendarAnnotations.festivalText(for: date), "清明节")
    }

    func test_festival_detects_thanksgiving() {
        let date = Calendar(identifier: .gregorian).date(from: DateComponents(year: 2026, month: 11, day: 26))!
        XCTAssertEqual(CalendarAnnotations.festivalText(for: date), "感恩节")
    }

    func test_festival_detects_valentine_day() {
        let date = Calendar(identifier: .gregorian).date(from: DateComponents(year: 2026, month: 2, day: 14))!
        XCTAssertEqual(CalendarAnnotations.festivalText(for: date), "情人节")
    }

    func test_festival_detects_christmas() {
        let date = Calendar(identifier: .gregorian).date(from: DateComponents(year: 2026, month: 12, day: 25))!
        XCTAssertEqual(CalendarAnnotations.festivalText(for: date), "圣诞节")
    }

    func test_festival_detects_spring_festival() {
        let date = Calendar(identifier: .gregorian).date(from: DateComponents(year: 2026, month: 2, day: 17))!
        XCTAssertEqual(CalendarAnnotations.festivalText(for: date), "春节")
    }

    func test_festival_detects_dragon_boat() {
        let date = Calendar(identifier: .gregorian).date(from: DateComponents(year: 2026, month: 6, day: 19))!
        XCTAssertEqual(CalendarAnnotations.festivalText(for: date), "端午节")
    }

    func test_festival_detects_mid_autumn() {
        let date = Calendar(identifier: .gregorian).date(from: DateComponents(year: 2026, month: 9, day: 25))!
        XCTAssertEqual(CalendarAnnotations.festivalText(for: date), "中秋节")
    }
}
