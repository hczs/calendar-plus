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
        updateStatusItemAppearance()
        statusItem.button?.target = self
        statusItem.button?.action = #selector(togglePopover)
        settingsObserver = NotificationCenter.default.addObserver(
            forName: .settingsStoreDidChange,
            object: settingsStore,
            queue: .main
        ) { [weak self] _ in
            MainActor.assumeIsolated {
                self?.updateStatusItemAppearance()
            }
        }
        activeObserver = NotificationCenter.default.addObserver(
            forName: NSApplication.didBecomeActiveNotification,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            MainActor.assumeIsolated {
                self?.updateStatusItemAppearance()
            }
        }
    }

    @objc private func togglePopover() {
        popoverController.toggle(relativeTo: statusItem.button)
    }

    private func updateStatusItemAppearance() {
        guard let button = statusItem.button else { return }
        switch settingsStore.statusIconMode {
        case .fixedIcon:
            button.title = ""
            button.image = AppBrandResources.statusBarIcon()
            button.imagePosition = .imageOnly
        case .todayDate:
            button.image = nil
            button.imagePosition = .noImage
            button.title = StatusBarTitleFormatter.title(
                for: .todayDate,
                on: Date(),
                calendar: CalendarGregorian.shanghai
            )
        }
    }
}
