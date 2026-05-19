import AppKit

@MainActor
final class PopoverController: NSObject, NSPopoverDelegate {
    private let popover = NSPopover()
    private var globalEventMonitor: Any?
    private var localEventMonitor: Any?
    private weak var anchorButton: NSStatusBarButton?

    init(settingsStore: SettingsStore) {
        super.init()
        let service = HolidayService(
            apiClient: URLSessionHolidayAPIClient(),
            cacheStore: HolidayCacheStore()
        )
        popover.contentViewController = CalendarRootViewController(
            holidayService: service,
            settingsStore: settingsStore
        )
        popover.behavior = .transient
        popover.delegate = self
    }

    func toggle(relativeTo button: NSStatusBarButton?) {
        guard let button else { return }
        anchorButton = button
        if popover.isShown {
            popover.performClose(nil)
        } else {
            popover.show(relativeTo: button.bounds, of: button, preferredEdge: .minY)
            startClickOutsideMonitor()
        }
    }

    private func startClickOutsideMonitor() {
        stopClickOutsideMonitor()

        globalEventMonitor = NSEvent.addGlobalMonitorForEvents(matching: [.leftMouseDown, .rightMouseDown]) { [weak self] event in
            Task { @MainActor in
                self?.closeIfClickOutside(event)
            }
        }

        localEventMonitor = NSEvent.addLocalMonitorForEvents(matching: [.leftMouseDown, .rightMouseDown]) { [weak self] event in
            Task { @MainActor in
                self?.closeIfClickOutside(event)
            }
            return event
        }
    }

    private func stopClickOutsideMonitor() {
        if let globalEventMonitor {
            NSEvent.removeMonitor(globalEventMonitor)
            self.globalEventMonitor = nil
        }
        if let localEventMonitor {
            NSEvent.removeMonitor(localEventMonitor)
            self.localEventMonitor = nil
        }
    }

    private func closeIfClickOutside(_ event: NSEvent) {
        guard popover.isShown else { return }

        if let anchorButton, event.window === anchorButton.window {
            let locationInButton = anchorButton.convert(event.locationInWindow, from: nil)
            if anchorButton.bounds.contains(locationInButton) {
                return
            }
        }

        guard let popoverWindow = popover.contentViewController?.view.window else {
            popover.performClose(nil)
            return
        }

        let clickLocation = event.locationInWindow
        if event.window === popoverWindow, popoverWindow.contentView?.hitTest(clickLocation) != nil {
            return
        }

        popover.performClose(nil)
    }

    func popoverDidClose(_ notification: Notification) {
        stopClickOutsideMonitor()
    }

    var installsClickOutsideMonitorForTest: Bool {
        globalEventMonitor != nil || localEventMonitor != nil
    }
}
