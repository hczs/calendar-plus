import XCTest
@testable import CalendarPlus

final class CalendarViewModelTests: XCTestCase {
    @MainActor
    func test_update_displayed_month_loads_cached_records_for_that_year() {
        let service = YearKeyedHolidayService()
        service.cached[2025] = [HolidayRecord(date: "2025-12-31", isHoliday: true, name: "元旦")]
        service.cached[2026] = [HolidayRecord(date: "2026-01-01", isHoliday: true, name: "元旦")]

        let vm = CalendarViewModel(service: service, initialDate: date(year: 2026, month: 1, day: 10))
        XCTAssertEqual(vm.holidayRecords.first?.date, "2026-01-01")

        vm.updateDisplayedMonth(date(year: 2025, month: 12, day: 1))
        XCTAssertEqual(vm.displayedYear, 2025)
        XCTAssertEqual(vm.holidayRecords.first?.date, "2025-12-31")
    }

    @MainActor
    func test_refresh_uses_displayed_year_and_sets_message() async {
        let service = YearKeyedHolidayService()
        let vm = CalendarViewModel(service: service, initialDate: date(year: 2025, month: 6, day: 1))

        await vm.refreshTapped()

        XCTAssertEqual(service.refreshedYears, [2025])
        XCTAssertEqual(vm.message, "已更新")
    }

    @MainActor
    func test_refresh_failure_sets_message() async {
        let service = YearKeyedHolidayService()
        service.shouldFailRefresh = true
        let vm = CalendarViewModel(service: service)

        await vm.refreshTapped()

        XCTAssertEqual(vm.message, "更新失败")
    }

    private func date(year: Int, month: Int, day: Int) -> Date {
        CalendarGregorian.shanghai.date(from: DateComponents(year: year, month: month, day: day))!
    }
}

@MainActor
private final class YearKeyedHolidayService: HolidayRefreshing {
    var cached: [Int: [HolidayRecord]] = [:]
    var refreshedYears: [Int] = []
    var shouldFailRefresh = false

    func refresh(year: Int) async throws -> [HolidayRecord] {
        refreshedYears.append(year)
        if shouldFailRefresh {
            throw URLError(.notConnectedToInternet)
        }
        let records = [HolidayRecord(date: "\(year)-01-01", isHoliday: true, name: "元旦")]
        cached[year] = records
        return records
    }

    func loadCached(year: Int) -> [HolidayRecord] {
        cached[year] ?? []
    }
}
