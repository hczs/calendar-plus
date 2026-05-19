import AppKit

@MainActor
final class SettingsViewController: NSViewController {
    private enum Layout {
        static let toolbarHeight: CGFloat = 44
        static let horizontalPadding: CGFloat = 12
        static let sectionTop: CGFloat = 16
        static let rowGap: CGFloat = 8
        static let labelHeight: CGFloat = 20
        static let controlHeight: CGFloat = 28
    }

    private let store: SettingsStore
    private let toolbarView = NSView(frame: .zero)
    private let titleLabel = NSTextField(labelWithString: "设置")
    private let themeLabel = NSTextField(labelWithString: "主题")
    private let themeControl = NSSegmentedControl(labels: ["系统", "浅色", "深色"], trackingMode: .selectOne, target: nil, action: nil)
    private let statusIconLabel = NSTextField(labelWithString: "菜单栏图标")
    private let statusIconControl = NSSegmentedControl(labels: ["固定日历", "今日日期"], trackingMode: .selectOne, target: nil, action: nil)
    private let backButton = NSButton(title: "返回", target: nil, action: nil)
    private let dividerView = NSBox()

    var onBackTapped: (() -> Void)?
    var onThemeChanged: ((ThemeMode) -> Void)?

    init(store: SettingsStore) {
        self.store = store
        super.init(nibName: nil, bundle: nil)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func loadView() {
        view = NSView(frame: NSRect(x: 0, y: 0, width: 432, height: 420))
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.wantsLayer = true

        toolbarView.wantsLayer = true
        view.addSubview(toolbarView)

        titleLabel.font = .systemFont(ofSize: 17, weight: .semibold)
        toolbarView.addSubview(titleLabel)

        backButton.bezelStyle = .accessoryBar
        backButton.isBordered = false
        backButton.font = .systemFont(ofSize: 15, weight: .semibold)
        backButton.target = self
        backButton.action = #selector(backTapped)
        toolbarView.addSubview(backButton)

        dividerView.boxType = .separator
        view.addSubview(dividerView)

        themeLabel.font = .systemFont(ofSize: 14, weight: .semibold)
        view.addSubview(themeLabel)

        themeControl.target = self
        themeControl.action = #selector(themeChanged)
        themeControl.segmentStyle = .rounded
        view.addSubview(themeControl)

        statusIconLabel.font = .systemFont(ofSize: 14, weight: .semibold)
        view.addSubview(statusIconLabel)

        statusIconControl.target = self
        statusIconControl.action = #selector(statusIconChanged)
        statusIconControl.segmentStyle = .rounded
        view.addSubview(statusIconControl)

        applyFromStore()
        applyThemeStyle()
    }

    override func viewDidLayout() {
        super.viewDidLayout()

        toolbarView.frame = NSRect(
            x: 0,
            y: view.bounds.height - Layout.toolbarHeight,
            width: view.bounds.width,
            height: Layout.toolbarHeight
        )
        titleLabel.frame = NSRect(x: Layout.horizontalPadding, y: 10, width: 120, height: 24)
        backButton.frame = NSRect(
            x: toolbarView.bounds.width - Layout.horizontalPadding - 60,
            y: 8,
            width: 60,
            height: 28
        )

        let dividerY = toolbarView.frame.minY - 1
        dividerView.frame = NSRect(x: 0, y: dividerY, width: view.bounds.width, height: 1)

        let contentWidth = view.bounds.width - Layout.horizontalPadding * 2
        var y = dividerY - Layout.sectionTop - Layout.labelHeight
        themeLabel.frame = NSRect(x: Layout.horizontalPadding, y: y, width: contentWidth, height: Layout.labelHeight)
        y -= Layout.rowGap + Layout.controlHeight
        themeControl.frame = NSRect(x: Layout.horizontalPadding, y: y, width: min(contentWidth, 220), height: Layout.controlHeight)

        y -= Layout.sectionTop + Layout.labelHeight
        statusIconLabel.frame = NSRect(x: Layout.horizontalPadding, y: y, width: contentWidth, height: Layout.labelHeight)
        y -= Layout.rowGap + Layout.controlHeight
        statusIconControl.frame = NSRect(x: Layout.horizontalPadding, y: y, width: min(contentWidth, 220), height: Layout.controlHeight)

        applyThemeStyle()
    }

    private func applyFromStore() {
        switch store.themeMode {
        case .system:
            themeControl.selectedSegment = 0
        case .light:
            themeControl.selectedSegment = 1
        case .dark:
            themeControl.selectedSegment = 2
        }

        switch store.statusIconMode {
        case .fixedIcon:
            statusIconControl.selectedSegment = 0
        case .todayDate:
            statusIconControl.selectedSegment = 1
        }
    }

    @objc private func themeChanged() {
        let mode: ThemeMode
        switch themeControl.selectedSegment {
        case 1:
            mode = .light
        case 2:
            mode = .dark
        default:
            mode = .system
        }

        store.themeMode = mode
        onThemeChanged?(mode)
    }

    @objc private func statusIconChanged() {
        store.statusIconMode = statusIconControl.selectedSegment == 1 ? .todayDate : .fixedIcon
    }

    @objc private func backTapped() {
        onBackTapped?()
    }

    func selectThemeForTest(_ mode: ThemeMode) {
        store.themeMode = mode
        onThemeChanged?(mode)
        applyFromStore()
    }

    func refreshTheme() {
        applyThemeStyle()
    }

    private func applyThemeStyle() {
        let theme = CalendarTheme.current(for: view.effectiveAppearance)
        view.layer?.backgroundColor = theme.background.cgColor
        toolbarView.layer?.backgroundColor = theme.background.cgColor
        titleLabel.textColor = theme.headerText
        themeLabel.textColor = theme.headerText
        statusIconLabel.textColor = theme.headerText
        backButton.contentTintColor = theme.secondaryIcon
    }
}
