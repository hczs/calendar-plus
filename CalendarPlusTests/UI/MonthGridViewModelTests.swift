import XCTest
@testable import CalendarPlus

final class MonthGridViewModelTests: XCTestCase {
    func test_day_cell_shows_holiday_badge_when_isHoliday_true() {
        let vm = DayCellViewModel(day: 1, isToday: false, isSelected: false, isHoliday: true)
        XCTAssertEqual(vm.badgeText, "假")
    }
}
