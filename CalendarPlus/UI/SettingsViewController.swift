import AppKit

@MainActor
final class SettingsViewController: NSViewController {
    private let store: SettingsStore
    private let titleLabel = NSTextField(labelWithString: "设置")
    private let themeLabel = NSTextField(labelWithString: "主题")
    private let themeControl = NSSegmentedControl(labels: ["系统", "浅色", "深色"], trackingMode: .selectOne, target: nil, action: nil)
    private let statusIconLabel = NSTextField(labelWithString: "菜单栏图标")
    private let statusIconControl = NSSegmentedControl(labels: ["固定日历", "今日日期"], trackingMode: .selectOne, target: nil, action: nil)
    private let backButton = NSButton(title: "返回", target: nil, action: nil)
    private let contentCard = NSView(frame: .zero)

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
        view = NSView(frame: NSRect(x: 0, y: 0, width: 400, height: 460))
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.wantsLayer = true
        contentCard.wantsLayer = true
        contentCard.layer?.cornerRadius = 14
        contentCard.layer?.borderWidth = 1
        view.addSubview(contentCard)

        titleLabel.font = .systemFont(ofSize: 20, weight: .bold)
        contentCard.addSubview(titleLabel)

        themeLabel.font = .systemFont(ofSize: 14, weight: .semibold)
        contentCard.addSubview(themeLabel)

        themeControl.target = self
        themeControl.action = #selector(themeChanged)
        themeControl.segmentStyle = .rounded
        contentCard.addSubview(themeControl)

        statusIconLabel.font = .systemFont(ofSize: 14, weight: .semibold)
        contentCard.addSubview(statusIconLabel)

        statusIconControl.target = self
        statusIconControl.action = #selector(statusIconChanged)
        statusIconControl.segmentStyle = .rounded
        contentCard.addSubview(statusIconControl)

        backButton.bezelStyle = .rounded
        backButton.target = self
        backButton.action = #selector(backTapped)
        contentCard.addSubview(backButton)

        applyFromStore()
        applyThemeStyle()
    }

    override func viewDidLayout() {
        super.viewDidLayout()
        contentCard.frame = NSRect(x: 8, y: 8, width: view.bounds.width - 16, height: view.bounds.height - 16)
        titleLabel.frame = NSRect(x: 24, y: contentCard.bounds.height - 54, width: 120, height: 28)
        backButton.frame = NSRect(x: contentCard.bounds.width - 82, y: contentCard.bounds.height - 52, width: 60, height: 28)
        themeLabel.frame = NSRect(x: 24, y: contentCard.bounds.height - 108, width: 80, height: 20)
        themeControl.frame = NSRect(x: 24, y: contentCard.bounds.height - 140, width: 220, height: 28)
        statusIconLabel.frame = NSRect(x: 24, y: contentCard.bounds.height - 186, width: 120, height: 20)
        statusIconControl.frame = NSRect(x: 24, y: contentCard.bounds.height - 218, width: 220, height: 28)
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
        contentCard.layer?.backgroundColor = theme.cardBackground.cgColor
        contentCard.layer?.borderColor = theme.border.cgColor
        titleLabel.textColor = theme.headerText
        themeLabel.textColor = theme.headerText
        statusIconLabel.textColor = theme.headerText
        backButton.contentTintColor = theme.secondaryIcon
        backButton.bezelColor = theme.footerBackground
        backButton.attributedTitle = NSAttributedString(
            string: "返回",
            attributes: [
                .foregroundColor: theme.dayText,
                .font: NSFont.systemFont(ofSize: 15, weight: .semibold)
            ]
        )
    }
}
