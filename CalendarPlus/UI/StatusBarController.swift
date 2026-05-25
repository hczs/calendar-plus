import AppKit

@MainActor
final class StatusBarController: NSObject {
    let statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
    let popoverController: PopoverController
    private let settingsStore: SettingsStore
    private var settingsObserver: NSObjectProtocol?
    private var activeObserver: NSObjectProtocol?
    private lazy var contextMenu: NSMenu = {
        let menu = NSMenu()
        let quitItem = NSMenuItem(title: "退出", action: #selector(quitApplication), keyEquivalent: "")
        quitItem.target = self
        menu.addItem(quitItem)
        return menu
    }()

    init(settingsStore: SettingsStore = SettingsStore()) {
        self.settingsStore = settingsStore
        self.popoverController = PopoverController(settingsStore: settingsStore)
        super.init()
        updateStatusItemAppearance()
        statusItem.button?.target = self
        statusItem.button?.action = #selector(statusBarButtonClicked)
        statusItem.button?.sendAction(on: [.leftMouseUp, .rightMouseUp])
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

    @objc private func statusBarButtonClicked(_ sender: NSStatusBarButton) {
        guard let event = NSApp.currentEvent else { return }
        if event.type == .rightMouseUp {
            contextMenu.popUp(positioning: nil, at: NSPoint(x: 0, y: sender.bounds.height), in: sender)
            return
        }
        popoverController.toggle(relativeTo: sender)
    }

    @objc private func quitApplication() {
        NSApp.terminate(nil)
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
