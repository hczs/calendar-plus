import AppKit

@MainActor
final class StatusBarController: NSObject {
    let statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
    let popoverController: PopoverController
    private let settingsStore: SettingsStore
    private var settingsObserver: NSObjectProtocol?
    private var activeObserver: NSObjectProtocol?

    init(settingsStore: SettingsStore = SettingsStore()) {
        self.settingsStore = settingsStore
        self.popoverController = PopoverController(settingsStore: settingsStore)
        super.init()
        updateTitle()
        statusItem.button?.target = self
        statusItem.button?.action = #selector(togglePopover)
        settingsObserver = NotificationCenter.default.addObserver(
            forName: .settingsStoreDidChange,
            object: settingsStore,
            queue: .main
        ) { [weak self] _ in
            MainActor.assumeIsolated {
                self?.updateTitle()
            }
        }
        activeObserver = NotificationCenter.default.addObserver(
            forName: NSApplication.didBecomeActiveNotification,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            MainActor.assumeIsolated {
                self?.updateTitle()
            }
        }
    }

    @objc private func togglePopover() {
        popoverController.toggle(relativeTo: statusItem.button)
    }

    private func updateTitle() {
        statusItem.button?.title = StatusBarTitleFormatter.title(
            for: settingsStore.statusIconMode,
            on: Date(),
            calendar: CalendarGregorian.shanghai
        )
    }
}
