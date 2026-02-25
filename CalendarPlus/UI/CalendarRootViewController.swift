import AppKit

@MainActor
protocol HolidayRefreshing {
    func refresh(year: Int) async throws -> [HolidayRecord]
    func loadCached(year: Int) -> [HolidayRecord]
}

extension HolidayService: HolidayRefreshing {}

extension HolidayRefreshing {
    func loadCached(year: Int) -> [HolidayRecord] { [] }
}

@MainActor
final class CalendarViewModel {
    private let service: HolidayRefreshing
    private(set) var isRefreshEnabled = true
    private(set) var message: String?
    private(set) var holidayRecords: [HolidayRecord] = []

    init(service: HolidayRefreshing) {
        self.service = service
        let year = Calendar.current.component(.year, from: Date())
        self.holidayRecords = service.loadCached(year: year)
    }

    func refreshTapped() async {
        isRefreshEnabled = false
        defer { isRefreshEnabled = true }

        do {
            let year = Calendar.current.component(.year, from: Date())
            holidayRecords = try await service.refresh(year: year)
            message = "已更新"
        } catch {
            message = "更新失败"
        }
    }
}

final class CalendarRootViewController: NSViewController {
    private let monthGridView = MonthGridView(frame: .zero)
    private let holidayService: HolidayService?
    private var viewModel: CalendarViewModel?

    init(holidayService: HolidayService? = nil) {
        self.holidayService = holidayService
        super.init(nibName: nil, bundle: nil)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func loadView() {
        view = NSView(frame: NSRect(x: 0, y: 0, width: 400, height: 460))
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        monthGridView.frame = view.bounds
        monthGridView.autoresizingMask = [.width, .height]
        view.addSubview(monthGridView)

        if let holidayService {
            let vm = CalendarViewModel(service: holidayService)
            viewModel = vm
            monthGridView.bind(viewModel: vm)
            if vm.holidayRecords.isEmpty {
                Task { [weak self] in
                    await vm.refreshTapped()
                    self?.monthGridView.bind(viewModel: vm)
                }
            }
        }
    }
}
