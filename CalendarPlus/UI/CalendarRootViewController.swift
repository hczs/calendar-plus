import AppKit

@MainActor
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
        view = NSView(frame: NSRect(x: 0, y: 0, width: 360, height: 420))
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

        guard let holidayService else { return }

        let vm = CalendarViewModel(service: holidayService)
        viewModel = vm
        monthGridView.onDisplayedMonthChanged = { [weak vm] date in
            vm?.updateDisplayedMonth(date)
        }
        vm.onStateChanged = { [weak self, weak vm] in
            guard let self, let vm else { return }
            monthGridView.bind(viewModel: vm)
        }
        monthGridView.bind(viewModel: vm)

        if vm.holidayRecords.isEmpty {
            Task { [weak vm] in
                await vm?.refreshTapped()
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
