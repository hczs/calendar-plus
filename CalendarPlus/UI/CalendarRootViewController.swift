import AppKit

@MainActor
protocol HolidayRefreshing {
    func refresh(year: Int) async throws -> [HolidayRecord]
}

extension HolidayService: HolidayRefreshing {}

@MainActor
final class CalendarViewModel {
    private let service: HolidayRefreshing
    private(set) var isRefreshEnabled = true
    private(set) var message: String?

    init(service: HolidayRefreshing) {
        self.service = service
    }

    func refreshTapped() async {
        isRefreshEnabled = false
        defer { isRefreshEnabled = true }

        do {
            let year = Calendar.current.component(.year, from: Date())
            _ = try await service.refresh(year: year)
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
        view = NSView(frame: NSRect(x: 0, y: 0, width: 320, height: 380))
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
        }
    }
}
