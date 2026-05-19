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
    func test_update_displayed_month_notifies_on_same_year_month_change() {
        let service = YearKeyedHolidayService()
        service.cached[2026] = [HolidayRecord(date: "2026-06-01", isHoliday: true, name: "儿童节")]
        let vm = CalendarViewModel(service: service, initialDate: date(year: 2026, month: 5, day: 10))
        var notifyCount = 0
        vm.onStateChanged = { notifyCount += 1 }

        vm.updateDisplayedMonth(date(year: 2026, month: 6, day: 1))

        XCTAssertEqual(notifyCount, 1)
        XCTAssertEqual(vm.displayedYear, 2026)
        XCTAssertEqual(vm.holidayRecords.first?.date, "2026-06-01")
    }

    @MainActor
    func test_update_displayed_month_fetches_when_cache_empty_for_year() async {
        let service = YearKeyedHolidayService()
        let vm = CalendarViewModel(service: service, initialDate: date(year: 2026, month: 1, day: 10))

        vm.updateDisplayedMonth(date(year: 2025, month: 12, day: 1))
        XCTAssertEqual(vm.displayedYear, 2025)

        for _ in 0..<50 {
            if !vm.holidayRecords.isEmpty { break }
            try? await Task.sleep(nanoseconds: 10_000_000)
        }

        XCTAssertEqual(vm.holidayRecords.first?.date, "2025-01-01")
        XCTAssertEqual(service.refreshedYears, [2025])
        XCTAssertNil(vm.message)
    }

    @MainActor
    func test_refresh_failure_sets_message() async {
        let service = YearKeyedHolidayService()
        service.shouldFailRefresh = true
        let vm = CalendarViewModel(service: service)

        await vm.refreshTapped()

        XCTAssertEqual(vm.message, "更新失败")
    }

    @MainActor
    func test_refresh_message_clears_after_display_duration() async {
        let service = YearKeyedHolidayService()
        let vm = CalendarViewModel(service: service, messageDisplayDuration: 0.05)

        await vm.refreshTapped()
        XCTAssertEqual(vm.message, "已更新")

        try? await Task.sleep(nanoseconds: 80_000_000)
        XCTAssertNil(vm.message)
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
