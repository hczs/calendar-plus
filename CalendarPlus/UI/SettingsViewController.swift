import AppKit

@MainActor
final class SettingsViewController: NSViewController {
    private let store: SettingsStore

    init(store: SettingsStore) {
        self.store = store
        super.init(nibName: nil, bundle: nil)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func loadView() {
        view = NSView(frame: NSRect(x: 0, y: 0, width: 180, height: 80))
    }
}
