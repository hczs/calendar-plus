import Foundation

@MainActor
protocol HolidayRefreshing {
    func refresh(year: Int) async throws -> [HolidayRecord]
    func loadCached(year: Int) -> [HolidayRecord]
}

extension HolidayService: HolidayRefreshing {}

@MainActor
final class CalendarViewModel {
    private let service: HolidayRefreshing
    private(set) var isRefreshEnabled = true
    private(set) var message: String?
    private(set) var holidayRecords: [HolidayRecord] = []
    private(set) var displayedYear: Int

    var onStateChanged: (() -> Void)?

    init(service: HolidayRefreshing, initialDate: Date = Date()) {
        self.service = service
        displayedYear = CalendarGregorian.shanghai.component(.year, from: initialDate)
        holidayRecords = service.loadCached(year: displayedYear)
    }

    func updateDisplayedMonth(_ date: Date) {
        let year = CalendarGregorian.shanghai.component(.year, from: date)
        guard year != displayedYear else { return }
        displayedYear = year
        holidayRecords = service.loadCached(year: year)
        onStateChanged?()
    }

    func refreshTapped() async {
        isRefreshEnabled = false
        defer { isRefreshEnabled = true }

        do {
            holidayRecords = try await service.refresh(year: displayedYear)
            message = "已更新"
        } catch {
            message = "更新失败"
        }
        onStateChanged?()
    }
}
