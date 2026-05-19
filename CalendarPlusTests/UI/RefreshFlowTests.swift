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

    @MainActor
    func test_month_grid_shows_refresh_message_from_view_model() async {
        let service = ImmediateHolidayService()
        let vm = CalendarViewModel(service: service)
        let sut = MonthGridView(frame: NSRect(x: 0, y: 0, width: 320, height: 380))
        vm.onStateChanged = { [weak sut, weak vm] in
            guard let sut, let vm else { return }
            sut.bind(viewModel: vm)
        }
        sut.bind(viewModel: vm)

        await vm.refreshTapped()

        XCTAssertEqual(sut.statusMessageForTest, "已更新")
    }

    @MainActor
    func test_month_grid_hides_refresh_message_after_auto_dismiss() async {
        let service = ImmediateHolidayService()
        let vm = CalendarViewModel(service: service, messageDisplayDuration: 0.05)
        let sut = MonthGridView(frame: NSRect(x: 0, y: 0, width: 320, height: 380))
        vm.onStateChanged = { [weak sut, weak vm] in
            guard let sut, let vm else { return }
            sut.bind(viewModel: vm)
        }
        sut.bind(viewModel: vm)

        await vm.refreshTapped()
        XCTAssertEqual(sut.statusMessageForTest, "已更新")

        try? await Task.sleep(nanoseconds: 80_000_000)
        sut.bind(viewModel: vm)

        XCTAssertEqual(sut.statusMessageForTest, "")
    }
}

@MainActor
private struct DelayedHolidayService: HolidayRefreshing {
    func refresh(year: Int) async throws -> [HolidayRecord] {
        try await Task.sleep(nanoseconds: 10_000_000)
        return []
    }

    func loadCached(year: Int) -> [HolidayRecord] { [] }
}

@MainActor
private struct ImmediateHolidayService: HolidayRefreshing {
    func refresh(year: Int) async throws -> [HolidayRecord] {
        [HolidayRecord(date: "\(year)-01-01", isHoliday: true, name: nil)]
    }

    func loadCached(year: Int) -> [HolidayRecord] { [] }
}
