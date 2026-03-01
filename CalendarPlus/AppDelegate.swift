import AppKit

@MainActor
final class AppDelegate: NSObject, NSApplicationDelegate {
    private var statusBarController: StatusBarController?

    func applicationDidFinishLaunching(_ notification: Notification) {
        statusBarController = StatusBarController()
    }

    func makeStatusBarControllerForTest() -> StatusBarController {
        StatusBarController()
    }
}

@MainActor
public enum CalendarPlusLauncher {
    private static var retainedDelegate: AppDelegate?

    public static func run() {
        let app = NSApplication.shared
        app.setActivationPolicy(.accessory)

        let delegate = AppDelegate()
        retainedDelegate = delegate
        app.delegate = delegate
        app.run()
    }
}
