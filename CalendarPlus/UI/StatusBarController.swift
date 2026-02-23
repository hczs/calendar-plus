import AppKit

@MainActor
final class StatusBarController: NSObject {
    let statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
    let popoverController = PopoverController()
    private let settingsStore: SettingsStore

    init(settingsStore: SettingsStore = SettingsStore()) {
        self.settingsStore = settingsStore
        super.init()
        updateTitle()
        statusItem.button?.target = self
        statusItem.button?.action = #selector(togglePopover)
    }

    @objc private func togglePopover() {
        popoverController.toggle(relativeTo: statusItem.button)
    }

    private func updateTitle() {
        switch settingsStore.statusIconMode {
        case .fixedIcon:
            statusItem.button?.title = "📅"
        case .todayDate:
            let day = Calendar.current.component(.day, from: Date())
            statusItem.button?.title = "\(day)"
        }
    }
}
