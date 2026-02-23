import AppKit

@MainActor
final class StatusBarController: NSObject {
    let statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
    let popoverController = PopoverController()

    override init() {
        super.init()
        statusItem.button?.title = "📅"
        statusItem.button?.target = self
        statusItem.button?.action = #selector(togglePopover)
    }

    @objc private func togglePopover() {
        popoverController.toggle(relativeTo: statusItem.button)
    }
}
