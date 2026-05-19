import AppKit

@MainActor
final class TodayHeroView: NSView {
    private enum Layout {
        static let horizontalInset: CGFloat = 16
        static let dayFontSize: CGFloat = 30
        static let weekdayFontSize: CGFloat = 15
        static let subtitleFontSize: CGFloat = 12
        static let pillFontSize: CGFloat = 11
    }

    private static let weekdayFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "zh_CN")
        formatter.timeZone = CalendarGregorian.shanghai.timeZone
        formatter.dateFormat = "EEEE"
        return formatter
    }()

    private let dayLabel = NSTextField(labelWithString: "")
    private let weekdayLabel = NSTextField(labelWithString: "")
    private let subtitleLabel = NSTextField(labelWithString: "")
    private let pillLabel = NSTextField(labelWithString: "")
    private let dividerView = NSView(frame: .zero)

    private let holidayDateMatcher = HolidayDateMatcher()
    private let calendar = CalendarGregorian.shanghai

    override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
        wantsLayer = true

        dayLabel.font = .systemFont(ofSize: Layout.dayFontSize, weight: .semibold)
        addSubview(dayLabel)

        weekdayLabel.font = .systemFont(ofSize: Layout.weekdayFontSize, weight: .regular)
        addSubview(weekdayLabel)

        subtitleLabel.font = .systemFont(ofSize: Layout.subtitleFontSize, weight: .regular)
        subtitleLabel.lineBreakMode = .byTruncatingTail
        addSubview(subtitleLabel)

        pillLabel.font = .systemFont(ofSize: Layout.pillFontSize, weight: .medium)
        pillLabel.alignment = .center
        pillLabel.isBezeled = false
        pillLabel.isBordered = false
        pillLabel.drawsBackground = false
        pillLabel.wantsLayer = true
        pillLabel.layer?.cornerRadius = 6
        pillLabel.isHidden = true
        addSubview(pillLabel)

        dividerView.wantsLayer = true
        addSubview(dividerView)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func layout() {
        super.layout()

        let contentWidth = bounds.width - Layout.horizontalInset * 2
        dayLabel.frame = NSRect(x: Layout.horizontalInset, y: 28, width: 56, height: 34)
        weekdayLabel.frame = NSRect(x: Layout.horizontalInset + 60, y: 36, width: contentWidth - 60, height: 22)
        subtitleLabel.frame = NSRect(x: Layout.horizontalInset, y: 10, width: contentWidth, height: 16)

        if !pillLabel.isHidden {
            let pillSize = pillLabel.intrinsicContentSize
            let pillWidth = max(pillSize.width + 16, 52)
            pillLabel.frame = NSRect(
                x: bounds.width - Layout.horizontalInset - pillWidth,
                y: 30,
                width: pillWidth,
                height: 20
            )
        }

        dividerView.frame = NSRect(x: 0, y: 0, width: bounds.width, height: 1)
    }

    func configure(theme: CalendarTheme, holidayRecords: [HolidayRecord]) {
        let today = Date()
        let day = calendar.component(.day, from: today)
        dayLabel.stringValue = "\(day)"
        weekdayLabel.stringValue = Self.weekdayFormatter.string(from: today)

        let festival = CalendarAnnotations.festivalText(for: today)
        let lunar = CalendarAnnotations.lunarText(for: today)
        if let festival, !festival.isEmpty {
            subtitleLabel.stringValue = lunar.isEmpty ? festival : "\(festival) · \(lunar)"
        } else {
            subtitleLabel.stringValue = lunar
        }

        var markerType: DayMarkerType = .none
        if let record = holidayDateMatcher.matchingRecord(for: today, in: holidayRecords) {
            markerType = record.isHoliday ? .holiday : .makeupWorkday
        }
        let weekday = calendar.component(.weekday, from: today)
        let isWeekend = weekday == 1 || weekday == 7
        if markerType == .makeupWorkday && !isWeekend {
            markerType = .none
        }

        switch markerType {
        case .holiday:
            pillLabel.stringValue = "休息日"
            pillLabel.isHidden = false
            pillLabel.layer?.backgroundColor = theme.holidayTint.cgColor
            pillLabel.textColor = theme.primary
        case .makeupWorkday:
            pillLabel.stringValue = "补班"
            pillLabel.isHidden = false
            pillLabel.layer?.backgroundColor = theme.workdayTint.cgColor
            pillLabel.textColor = theme.workdayMarker
        case .none:
            pillLabel.isHidden = true
            pillLabel.stringValue = ""
        }

        layer?.backgroundColor = theme.elevated.cgColor
        dayLabel.textColor = theme.headerText
        weekdayLabel.textColor = theme.weekText
        subtitleLabel.textColor = theme.weekText
        dividerView.layer?.backgroundColor = theme.divider.cgColor

        needsLayout = true
    }

    var pillTextForTest: String {
        pillLabel.isHidden ? "" : pillLabel.stringValue
    }

    var subtitleTextForTest: String {
        subtitleLabel.stringValue
    }
}
