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
    private let settingsStore: SettingsStore
    private var viewModel: CalendarViewModel?
    private var settingsViewController: SettingsViewController?
    private var isShowingSettings = false

    init(holidayService: HolidayService? = nil, settingsStore: SettingsStore = SettingsStore()) {
        self.holidayService = holidayService
        self.settingsStore = settingsStore
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
        monthGridView.onSettingsTapped = { [weak self] in
            self?.showSettingsPage()
        }
        applyTheme()

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

    private func showSettingsPage() {
        if settingsViewController == nil {
            let vc = SettingsViewController(store: settingsStore)
            vc.onBackTapped = { [weak self] in
                self?.showCalendarPage()
            }
            vc.onThemeChanged = { [weak self] _ in
                self?.applyTheme()
                DispatchQueue.main.async { [weak self] in
                    self?.settingsViewController?.refreshTheme()
                }
            }
            settingsViewController = vc
        }

        guard let settingsVC = settingsViewController, !isShowingSettings else { return }
        addChild(settingsVC)
        settingsVC.view.frame = view.bounds
        settingsVC.view.autoresizingMask = [.width, .height]
        view.addSubview(settingsVC.view)
        monthGridView.isHidden = true
        isShowingSettings = true
    }

    private func showCalendarPage() {
        guard let settingsVC = settingsViewController, isShowingSettings else { return }
        settingsVC.view.removeFromSuperview()
        settingsVC.removeFromParent()
        monthGridView.isHidden = false
        isShowingSettings = false
    }

    private func applyTheme() {
        let appearance: NSAppearance?
        switch settingsStore.themeMode {
        case .system:
            appearance = nil
        case .light:
            appearance = NSAppearance(named: .aqua)
        case .dark:
            appearance = NSAppearance(named: .darkAqua)
        }

        view.appearance = appearance
        monthGridView.appearance = appearance
        settingsViewController?.view.appearance = appearance
    }

    var isShowingSettingsForTest: Bool {
        isShowingSettings
    }

    func showSettingsForTest() {
        showSettingsPage()
    }

    func selectThemeForTest(_ mode: ThemeMode) {
        showSettingsPage()
        settingsViewController?.selectThemeForTest(mode)
    }

    var appearanceNameForTest: NSAppearance.Name? {
        view.appearance?.name
    }
}
