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

    private var messageClearTask: Task<Void, Never>?
    private let messageDisplayDuration: TimeInterval

    init(
        service: HolidayRefreshing,
        initialDate: Date = Date(),
        messageDisplayDuration: TimeInterval = 2
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
        if holidayRecords.isEmpty {
            Task { await refreshDisplayedYear(showSuccessMessage: false) }
        }
    }

    func refreshTapped() async {
        await refreshDisplayedYear(showSuccessMessage: true)
    }

    private func refreshDisplayedYear(showSuccessMessage: Bool) async {
        guard isRefreshEnabled else { return }
        isRefreshEnabled = false
        defer { isRefreshEnabled = true }

        do {
            holidayRecords = try await service.refresh(year: displayedYear)
            if showSuccessMessage {
                message = "已更新"
                scheduleSuccessMessageClear()
            }
        } catch {
            messageClearTask?.cancel()
            message = "更新失败"
        }
        onStateChanged?()
    }

    private func scheduleSuccessMessageClear() {
        messageClearTask?.cancel()
        let duration = messageDisplayDuration
        messageClearTask = Task { [weak self] in
            try? await Task.sleep(nanoseconds: UInt64(duration * 1_000_000_000))
            guard let self, !Task.isCancelled else { return }
            if self.message == "已更新" {
                self.message = nil
                self.onStateChanged?()
            }
        }
    }
}
