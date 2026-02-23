import AppKit

final class CalendarRootViewController: NSViewController {
    private let monthGridView = MonthGridView(frame: .zero)

    override func loadView() {
        view = NSView(frame: NSRect(x: 0, y: 0, width: 320, height: 380))
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        monthGridView.frame = view.bounds
        monthGridView.autoresizingMask = [.width, .height]
        view.addSubview(monthGridView)
    }
}
