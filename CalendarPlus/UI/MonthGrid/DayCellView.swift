import AppKit

@MainActor
final class StyledDayCellView: NSView {
    private enum Layout {
        static let topInset: CGFloat = 5
        static let numberHeight: CGFloat = 18
        static let detailHeight: CGFloat = 11
        static let lineGap: CGFloat = 2
        static let todayBorderWidth: CGFloat = 2
        static let cornerRadius: CGFloat = 10
    }

    private let numberLabel = NSTextField(labelWithString: "")
    private let detailLabel = NSTextField(labelWithString: "")

    private(set) var day: Int?
    private(set) var markerType: DayMarkerType = .none
    private var shownFestivalText = ""
    private var shownLunarText = ""
    private var isToday = false
    private var isWeekend = false

    override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
        wantsLayer = true
        layer?.cornerRadius = Layout.cornerRadius

        numberLabel.alignment = .center
        numberLabel.font = .systemFont(ofSize: 15, weight: .semibold)
        addSubview(numberLabel)

        detailLabel.alignment = .center
        detailLabel.font = .systemFont(ofSize: 10, weight: .regular)
        detailLabel.lineBreakMode = .byTruncatingTail
        addSubview(detailLabel)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func layout() {
        super.layout()
        let numberY = bounds.height - Layout.topInset - Layout.numberHeight
        numberLabel.frame = NSRect(x: 0, y: numberY, width: bounds.width, height: Layout.numberHeight)
        let detailY = numberY - Layout.lineGap - Layout.detailHeight
        detailLabel.frame = NSRect(x: 0, y: detailY, width: bounds.width, height: Layout.detailHeight)
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
            layer?.backgroundColor = NSColor.clear.cgColor
            layer?.borderWidth = 0
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

        numberLabel.font = .systemFont(ofSize: 15, weight: isToday ? .bold : .semibold)
        numberLabel.textColor = isWeekend ? theme.primary : theme.dayText
        detailLabel.textColor = shownFestivalText.isEmpty ? theme.weekText : theme.primary

        switch markerType {
        case .holiday:
            layer?.backgroundColor = theme.holidayTint.cgColor
        case .makeupWorkday:
            layer?.backgroundColor = theme.workdayTint.cgColor
        case .none:
            layer?.backgroundColor = NSColor.clear.cgColor
        }

        if isToday {
            layer?.borderWidth = Layout.todayBorderWidth
            layer?.borderColor = theme.primary.cgColor
        } else {
            layer?.borderWidth = 0
            layer?.borderColor = nil
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

    var debugFestivalText: String { shownFestivalText }
    var debugLunarText: String { shownLunarText }
    var debugMarkerBadge: String {
        switch markerType {
        case .holiday: return "休"
        case .makeupWorkday: return "班"
        case .none: return ""
        }
    }

    var debugCornerTagText: String { debugMarkerBadge }

    var debugNumberColor: NSColor? { numberLabel.textColor }

    var debugUsesHolidayTintForTest: Bool {
        markerType == .holiday
    }
}
