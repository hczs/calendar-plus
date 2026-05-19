import AppKit

@MainActor
final class StyledDayCellView: NSView {
    private let numberLabel = NSTextField(labelWithString: "")
    private let detailLabel = NSTextField(labelWithString: "")
    private let cornerTagView = CornerTagView(frame: .zero)

    private(set) var day: Int?
    private(set) var markerType: DayMarkerType = .none
    private var shownFestivalText = ""
    private var shownLunarText = ""
    private var isToday = false
    private var isWeekend = false

    override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
        wantsLayer = true
        layer?.cornerRadius = 10

        numberLabel.alignment = .center
        numberLabel.font = .systemFont(ofSize: 18, weight: .medium)
        addSubview(numberLabel)

        detailLabel.alignment = .center
        detailLabel.font = .systemFont(ofSize: 10, weight: .regular)
        detailLabel.lineBreakMode = .byTruncatingTail
        addSubview(detailLabel)

        cornerTagView.wantsLayer = true
        cornerTagView.layer?.cornerRadius = 0
        cornerTagView.layer?.borderWidth = 1
        cornerTagView.isHidden = true
        addSubview(cornerTagView)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func layout() {
        super.layout()
        numberLabel.frame = NSRect(x: 0, y: bounds.height - 22, width: bounds.width, height: 16)
        detailLabel.frame = NSRect(x: 0, y: bounds.height - 33, width: bounds.width, height: 11)
        cornerTagView.frame = NSRect(x: bounds.maxX - 14, y: bounds.maxY - 14, width: 13, height: 13)
    }

    func configure(
        day: Int?,
        isToday: Bool,
        isWeekend: Bool,
        markerType: DayMarkerType,
        festivalText: String?,
        lunarText: String,
        theme: CalendarTheme
    ) {
        self.day = day
        self.isToday = isToday
        self.isWeekend = isWeekend
        self.markerType = markerType

        guard let day else {
            numberLabel.stringValue = ""
            detailLabel.stringValue = ""
            shownFestivalText = ""
            shownLunarText = ""
            cornerTagView.isHidden = true
            cornerTagView.text = ""
            layer?.backgroundColor = NSColor.clear.cgColor
            return
        }

        numberLabel.stringValue = "\(day)"
        if let festivalText, !festivalText.isEmpty {
            shownFestivalText = String(festivalText.prefix(6))
            shownLunarText = ""
            detailLabel.stringValue = shownFestivalText
        } else {
            shownFestivalText = ""
            shownLunarText = lunarText
            detailLabel.stringValue = shownLunarText
        }
        if isToday {
            layer?.backgroundColor = theme.primary.cgColor
            numberLabel.textColor = .white
            detailLabel.textColor = NSColor.white.withAlphaComponent(0.92)
            numberLabel.font = .systemFont(ofSize: 15, weight: .bold)
        } else {
            layer?.backgroundColor = NSColor.clear.cgColor
            numberLabel.font = .systemFont(ofSize: 14, weight: .medium)
            numberLabel.textColor = isWeekend ? theme.primary : theme.dayText
            detailLabel.textColor = shownFestivalText.isEmpty ? theme.weekText : theme.primary
        }

        switch markerType {
        case .holiday:
            cornerTagView.isHidden = false
            cornerTagView.fillColor = theme.primary
            cornerTagView.strokeColor = theme.primary
            cornerTagView.textColor = .white
            cornerTagView.text = "休"
        case .makeupWorkday:
            cornerTagView.isHidden = false
            cornerTagView.fillColor = theme.workdayMarker
            cornerTagView.strokeColor = theme.workdayMarker
            cornerTagView.textColor = .white
            cornerTagView.text = "班"
        case .none:
            cornerTagView.isHidden = true
            cornerTagView.text = ""
        }
    }

    var debugText: String {
        guard let day else { return "" }
        let festivalMark = shownFestivalText.isEmpty ? "" : "{\(shownFestivalText)}"
        let lunarMark = shownLunarText.isEmpty ? "" : "<\(shownLunarText)>"
        switch markerType {
        case .holiday:
            return "\(day)[H]\(festivalMark)\(lunarMark)"
        case .makeupWorkday:
            return "\(day)[W]\(festivalMark)\(lunarMark)"
        case .none:
            return "\(day)\(festivalMark)\(lunarMark)"
        }
    }

    var debugFestivalText: String {
        shownFestivalText
    }

    var debugLunarText: String {
        shownLunarText
    }

    var debugCornerTagText: String {
        cornerTagView.text
    }

    var debugNumberColor: NSColor? {
        numberLabel.textColor
    }
}

@MainActor
private final class CornerTagView: NSView {
    var text: String = "" {
        didSet { needsDisplay = true }
    }
    var fillColor: NSColor = .clear {
        didSet { needsDisplay = true }
    }
    var strokeColor: NSColor = .clear {
        didSet { needsDisplay = true }
    }
    var textColor: NSColor = .white {
        didSet { needsDisplay = true }
    }

    override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)
        guard !text.isEmpty else { return }

        fillColor.setFill()
        NSBezierPath(rect: bounds).fill()

        strokeColor.setStroke()
        let border = NSBezierPath(rect: bounds.insetBy(dx: 0.5, dy: 0.5))
        border.lineWidth = 1
        border.stroke()

        let attributes: [NSAttributedString.Key: Any] = [
            .font: NSFont.systemFont(ofSize: 8.5, weight: .bold),
            .foregroundColor: textColor
        ]
        let size = (text as NSString).size(withAttributes: attributes)
        let point = NSPoint(
            x: floor((bounds.width - size.width) / 2),
            y: floor((bounds.height - size.height) / 2)
        )
        (text as NSString).draw(at: point, withAttributes: attributes)
    }
}

enum DayMarkerType {
    case none
    case holiday
    case makeupWorkday
}

struct CalendarTheme {
    let background: NSColor
    let cardBackground: NSColor
    let border: NSColor
    let headerText: NSColor
    let weekText: NSColor
    let primary: NSColor
    let dayText: NSColor
    let workdayMarker: NSColor
    let footerBackground: NSColor
    let footerText: NSColor
    let secondaryIcon: NSColor

    static func current(for appearance: NSAppearance?) -> CalendarTheme {
        let isDark = appearance?.bestMatch(from: [.darkAqua, .aqua]) == .darkAqua
        if isDark {
            return CalendarTheme(
                background: NSColor(calibratedWhite: 0.12, alpha: 1),
                cardBackground: NSColor(calibratedRed: 0.16, green: 0.17, blue: 0.20, alpha: 0.95),
                border: NSColor(calibratedWhite: 1, alpha: 0.08),
                headerText: NSColor(calibratedWhite: 0.92, alpha: 1),
                weekText: NSColor(calibratedRed: 0.58, green: 0.63, blue: 0.72, alpha: 1),
                primary: NSColor(calibratedRed: 0.92, green: 0.16, blue: 0.20, alpha: 1),
                dayText: NSColor(calibratedWhite: 0.83, alpha: 1),
                workdayMarker: NSColor(calibratedRed: 0.20, green: 0.52, blue: 0.94, alpha: 1),
                footerBackground: NSColor(calibratedWhite: 0.10, alpha: 0.40),
                footerText: NSColor(calibratedRed: 0.70, green: 0.74, blue: 0.82, alpha: 1),
                secondaryIcon: NSColor(calibratedRed: 0.56, green: 0.62, blue: 0.72, alpha: 1)
            )
        }
        return CalendarTheme(
            background: NSColor(calibratedRed: 0.91, green: 0.94, blue: 0.98, alpha: 1),
            cardBackground: NSColor(calibratedRed: 0.98, green: 0.99, blue: 1.00, alpha: 1),
            border: NSColor(calibratedRed: 0.74, green: 0.79, blue: 0.87, alpha: 0.55),
            headerText: NSColor(calibratedRed: 0.15, green: 0.20, blue: 0.30, alpha: 1),
            weekText: NSColor(calibratedRed: 0.42, green: 0.50, blue: 0.63, alpha: 1),
            primary: NSColor(calibratedRed: 0.95, green: 0.20, blue: 0.24, alpha: 1),
            dayText: NSColor(calibratedRed: 0.18, green: 0.23, blue: 0.33, alpha: 1),
            workdayMarker: NSColor(calibratedRed: 0.20, green: 0.52, blue: 0.94, alpha: 1),
            footerBackground: NSColor(calibratedRed: 0.92, green: 0.94, blue: 0.97, alpha: 0.96),
            footerText: NSColor(calibratedRed: 0.30, green: 0.37, blue: 0.48, alpha: 1),
            secondaryIcon: NSColor(calibratedRed: 0.35, green: 0.43, blue: 0.56, alpha: 1)
        )
    }
}
