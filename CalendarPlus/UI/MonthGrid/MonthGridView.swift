import AppKit

@MainActor
final class MonthGridView: NSView {
    private let holidayDateMatcher = HolidayDateMatcher()
    private let refreshButton = NSButton(title: "刷新", target: nil, action: nil)
    private let messageLabel = NSTextField(labelWithString: "")
    private var viewModel: CalendarViewModel?

    override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
        refreshButton.target = self
        refreshButton.action = #selector(refreshTapped)
        addSubview(refreshButton)
        addSubview(messageLabel)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func layout() {
        super.layout()
        refreshButton.frame = NSRect(x: 12, y: bounds.height - 34, width: 72, height: 24)
        messageLabel.frame = NSRect(x: 92, y: bounds.height - 34, width: 180, height: 24)
    }

    func bind(viewModel: CalendarViewModel) {
        self.viewModel = viewModel
        render()
    }

    @objc private func refreshTapped() {
        guard let viewModel else { return }
        Task {
            await viewModel.refreshTapped()
            render()
        }
    }

    private func render() {
        refreshButton.isEnabled = viewModel?.isRefreshEnabled ?? true
        messageLabel.stringValue = viewModel?.message ?? ""
        _ = holidayDateMatcher
    }
}
