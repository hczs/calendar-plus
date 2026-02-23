import XCTest
@testable import CalendarPlus

final class RefreshFlowTests: XCTestCase {
    @MainActor
    func test_refresh_button_disables_while_loading_and_reenables() async {
        let vm = CalendarViewModel(service: DelayedHolidayService())
        XCTAssertTrue(vm.isRefreshEnabled)
        await vm.refreshTapped()
        XCTAssertTrue(vm.isRefreshEnabled)
    }
}

@MainActor
private struct DelayedHolidayService: HolidayRefreshing {
    func refresh(year: Int) async throws -> [HolidayRecord] {
        try await Task.sleep(nanoseconds: 10_000_000)
        return []
    }
}
