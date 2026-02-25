import AppKit

@MainActor
final class PopoverController {
    private let popover = NSPopover()

    init() {
        let service = HolidayService(
            apiClient: URLSessionHolidayAPIClient(),
            cacheStore: HolidayCacheStore()
        )
        popover.contentViewController = CalendarRootViewController(holidayService: service)
        popover.behavior = .transient
    }

    func toggle(relativeTo button: NSStatusBarButton?) {
        guard let button else { return }
        if popover.isShown {
            popover.performClose(nil)
        } else {
            popover.show(relativeTo: button.bounds, of: button, preferredEdge: .minY)
        }
    }
}
