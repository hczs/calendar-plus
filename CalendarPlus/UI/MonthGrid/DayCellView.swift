import AppKit

@MainActor
final class StyledDayCellView: NSView {
    private enum Layout {
        static let detailHeight: CGFloat = 11
        static let lineGap: CGFloat = 2
        static let todayBorderWidth: CGFloat = 2
        static let todayBorderWidthOnMarker: CGFloat = 2.5
        static let cornerRadius: CGFloat = 10
        static let badgeMinWidth: CGFloat = 10
        static let badgeHeight: CGFloat = 11
        /// 角标底边落在公历数字自上 1/3 处的水平线（与数字右上错开叠放）
        static let badgeAnchorFromNumberTop: CGFloat = 1.0 / 3.0
        static let badgeOverlapIntoNumber: CGFloat = 2
        static let numberHorizontalPadding: CGFloat = 2
    }

    private static func numberLineHeight(for font: NSFont) -> CGFloat {
        ceil(font.ascender - font.descender + font.leading) + 2
    }

    private static func badgeExtensionAboveNumber(for numberLineHeight: CGFloat) -> CGFloat {
        Layout.badgeHeight - numberLineHeight * Layout.badgeAnchorFromNumberTop
    }

    private static let accessibilityDateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "zh_CN")
        formatter.timeZone = CalendarGregorian.shanghai.timeZone
        formatter.dateFormat = "M月d日"
        return formatter
    }()

    private let numberLabel = NSTextField(labelWithString: "")
    private let detailLabel = NSTextField(labelWithString: "")
    private let markerBadgeLabel = NSTextField(labelWithString: "")

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
        layer?.masksToBounds = false

        numberLabel.alignment = .center
        numberLabel.font = .systemFont(ofSize: 15, weight: .semibold)
        if let cell = numberLabel.cell as? NSTextFieldCell {
            cell.usesSingleLineMode = true
            cell.lineBreakMode = .byClipping
        }
        addSubview(numberLabel)

        detailLabel.alignment = .center
        detailLabel.font = .systemFont(ofSize: 10, weight: .regular)
        detailLabel.lineBreakMode = .byTruncatingTail
        addSubview(detailLabel)

        markerBadgeLabel.alignment = .center
        markerBadgeLabel.font = .systemFont(ofSize: 10, weight: .semibold)
        markerBadgeLabel.isHidden = true
        addSubview(markerBadgeLabel)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func layout() {
        super.layout()

        let font = numberLabel.font ?? .systemFont(ofSize: 15, weight: .semibold)
        let numberLineHeight = Self.numberLineHeight(for: font)
        let showsBadge = !markerBadgeLabel.isHidden
        let extensionAbove = showsBadge ? Self.badgeExtensionAboveNumber(for: numberLineHeight) : 0
        let contentHeight = numberLineHeight + Layout.lineGap + Layout.detailHeight
        let blockHeight = contentHeight + extensionAbove
        let blockOriginY = (bounds.height - blockHeight) / 2

        let detailY = blockOriginY
        let numberY = blockOriginY + Layout.detailHeight + Layout.lineGap
        detailLabel.frame = NSRect(x: 0, y: detailY, width: bounds.width, height: Layout.detailHeight)

        let measuredNumberWidth = ceil((numberLabel.stringValue as NSString).size(
            withAttributes: [.font: font]
        ).width)
        let numberSlotWidth = measuredNumberWidth + Layout.numberHorizontalPadding * 2
        // 公历始终按格宽居中；角标挂在数字右上，占用加宽后的格子右侧空间，不参与居中计算
        let numberX = (bounds.width - numberSlotWidth) / 2

        numberLabel.frame = NSRect(
            x: numberX,
            y: numberY,
            width: numberSlotWidth,
            height: numberLineHeight
        )

        if showsBadge {
            let badgeWidth = max(ceil(markerBadgeLabel.intrinsicContentSize.width), Layout.badgeMinWidth)
            let numberTop = numberY + numberLineHeight
            let badgeBottomY = numberTop - numberLineHeight * Layout.badgeAnchorFromNumberTop
            markerBadgeLabel.frame = NSRect(
                x: numberX + numberSlotWidth - Layout.badgeOverlapIntoNumber,
                y: badgeBottomY,
                width: badgeWidth,
                height: Layout.badgeHeight
            )
        }
    }

    func configure(
        day: Int?,
        date: Date?,
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

        guard let day, let date else {
            numberLabel.stringValue = ""
            detailLabel.stringValue = ""
            shownFestivalText = ""
            shownLunarText = ""
            markerBadgeLabel.isHidden = true
            markerBadgeLabel.stringValue = ""
            layer?.backgroundColor = NSColor.clear.cgColor
            layer?.borderWidth = 0
            layer?.borderColor = nil
            setAccessibilityElement(false)
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
        let usesWeekendNumberColor = isWeekend && markerType != .makeupWorkday
        numberLabel.textColor = usesWeekendNumberColor ? theme.primary : theme.dayText

        if shownFestivalText.isEmpty {
            detailLabel.textColor = isWeekend ? theme.primary : theme.weekText
        } else {
            detailLabel.textColor = theme.primary
        }

        switch markerType {
        case .holiday:
            layer?.backgroundColor = theme.holidayTint.cgColor
            markerBadgeLabel.stringValue = "休"
            markerBadgeLabel.textColor = theme.primary
            markerBadgeLabel.isHidden = false
        case .makeupWorkday:
            layer?.backgroundColor = theme.workdayTint.cgColor
            markerBadgeLabel.stringValue = "班"
            markerBadgeLabel.textColor = theme.workdayMarker
            markerBadgeLabel.isHidden = false
        case .none:
            layer?.backgroundColor = NSColor.clear.cgColor
            markerBadgeLabel.isHidden = true
            markerBadgeLabel.stringValue = ""
        }

        if isToday {
            layer?.borderWidth = markerType == .none ? Layout.todayBorderWidth : Layout.todayBorderWidthOnMarker
            layer?.borderColor = theme.primary.cgColor
        } else {
            layer?.borderWidth = 0
            layer?.borderColor = nil
        }

        updateAccessibility(date: date, isToday: isToday, markerType: markerType)
        needsLayout = true
    }

    private func updateAccessibility(date: Date, isToday: Bool, markerType: DayMarkerType) {
        var parts = [Self.accessibilityDateFormatter.string(from: date)]
        if isToday {
            parts.append("今天")
        }
        switch markerType {
        case .holiday:
            parts.append("休息日")
        case .makeupWorkday:
            parts.append("补班")
        case .none:
            break
        }
        if !shownFestivalText.isEmpty {
            parts.append(shownFestivalText)
        } else if !shownLunarText.isEmpty {
            parts.append("农历\(shownLunarText)")
        }

        setAccessibilityElement(true)
        setAccessibilityRole(.staticText)
        setAccessibilityLabel(parts.joined(separator: "，"))
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

    var debugCornerTagText: String { markerBadgeLabel.isHidden ? "" : markerBadgeLabel.stringValue }

    var debugNumberColor: NSColor? { numberLabel.textColor }

    var debugDetailColor: NSColor? { detailLabel.textColor }

    var debugUsesHolidayTintForTest: Bool {
        markerType == .holiday
    }
}
