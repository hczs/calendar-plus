import AppKit

final class CalendarRootViewController: NSViewController {
    private let monthGridView = MonthGridView(frame: .zero)
    private let holidayService: HolidayService?

    init(holidayService: HolidayService? = nil) {
        self.holidayService = holidayService
        super.init(nibName: nil, bundle: nil)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func loadView() {
        view = NSView(frame: NSRect(x: 0, y: 0, width: 320, height: 380))
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        monthGridView.frame = view.bounds
        monthGridView.autoresizingMask = [.width, .height]
        view.addSubview(monthGridView)
        _ = holidayService
    }
}
