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
    private let messageDisplayDuration: TimeInterval
    private(set) var isRefreshEnabled = true
    private(set) var message: String?
    private(set) var holidayRecords: [HolidayRecord] = []
    private(set) var displayedYear: Int
    private var messageDismissTask: Task<Void, Never>?

    var onStateChanged: (() -> Void)?

    init(
        service: HolidayRefreshing,
        initialDate: Date = Date(),
        messageDisplayDuration: TimeInterval = 2.5
    ) {
        self.service = service
        self.messageDisplayDuration = messageDisplayDuration
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
            setTransientMessage("已更新")
        } catch {
            setTransientMessage("更新失败")
        }
    }

    private func setTransientMessage(_ text: String) {
        messageDismissTask?.cancel()
        message = text
        onStateChanged?()

        let duration = messageDisplayDuration
        messageDismissTask = Task { [weak self] in
            let nanoseconds = UInt64(duration * 1_000_000_000)
            try? await Task.sleep(nanoseconds: nanoseconds)
            guard !Task.isCancelled else { return }
            self?.clearMessage()
        }
    }

    private func clearMessage() {
        guard message != nil else { return }
        message = nil
        onStateChanged?()
    }
}
