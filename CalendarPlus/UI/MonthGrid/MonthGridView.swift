import AppKit

@MainActor
final class MonthGridView: NSView {
    private let holidayDateMatcher = HolidayDateMatcher()

    private let cardView = NSView(frame: .zero)
    private let headerView = NSView(frame: .zero)
    private let footerView = NSView(frame: .zero)

    private let monthTitleLabel = NSTextField(labelWithString: "")
    private let prevButton = NSButton(title: "", target: nil, action: nil)
    private let nextButton = NSButton(title: "", target: nil, action: nil)

    private let refreshButton = NSButton(title: "", target: nil, action: nil)
    private let settingsButton = NSButton(title: "", target: nil, action: nil)

    private var weekdayLabels: [NSTextField] = []
    private var dayCells: [StyledDayCellView] = []
    private var dayCellByDay: [Int: StyledDayCellView] = [:]

    private var viewModel: CalendarViewModel?
    private var markerByDate: [String: DayMarkerType] = [:]
    private var displayedMonthDate = Date()
    var onSettingsTapped: (() -> Void)?

    override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
        wantsLayer = true

        cardView.wantsLayer = true
        cardView.layer?.cornerRadius = 14
        addSubview(cardView)

        headerView.wantsLayer = true
        cardView.addSubview(headerView)
        footerView.wantsLayer = true
        cardView.addSubview(footerView)

        monthTitleLabel.font = .systemFont(ofSize: 16, weight: .bold)
        headerView.addSubview(monthTitleLabel)

        prevButton.bezelStyle = .texturedRounded
        prevButton.title = "‹"
        prevButton.target = self
        prevButton.action = #selector(showPreviousMonth)
        headerView.addSubview(prevButton)

        nextButton.bezelStyle = .texturedRounded
        nextButton.title = "›"
        nextButton.target = self
        nextButton.action = #selector(showNextMonth)
        headerView.addSubview(nextButton)

        refreshButton.bezelStyle = .texturedRounded
        refreshButton.image = NSImage(systemSymbolName: "arrow.clockwise", accessibilityDescription: nil)
        refreshButton.target = self
        refreshButton.action = #selector(refreshTapped)
        footerView.addSubview(refreshButton)

        settingsButton.bezelStyle = .texturedRounded
        settingsButton.image = NSImage(systemSymbolName: "gearshape", accessibilityDescription: nil)
        settingsButton.target = self
        settingsButton.action = #selector(settingsTapped)
        footerView.addSubview(settingsButton)

        buildStaticCalendar()
        render()
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidChangeEffectiveAppearance() {
        super.viewDidChangeEffectiveAppearance()
        applyDayStyles()
        applyThemeAndRender()
    }

    override func layout() {
        super.layout()

        cardView.frame = NSRect(x: 8, y: 8, width: bounds.width - 16, height: bounds.height - 16)
        headerView.frame = NSRect(x: 0, y: cardView.bounds.height - 60, width: cardView.bounds.width, height: 60)
        footerView.frame = NSRect(x: 0, y: 0, width: cardView.bounds.width, height: 46)
        cardView.addSubview(footerView, positioned: .above, relativeTo: nil)

        monthTitleLabel.frame = NSRect(x: 18, y: 20, width: 160, height: 24)
        prevButton.frame = NSRect(x: cardView.bounds.width - 80, y: 20, width: 28, height: 24)
        nextButton.frame = NSRect(x: cardView.bounds.width - 48, y: 20, width: 28, height: 24)

        settingsButton.frame = NSRect(x: cardView.bounds.width - 74, y: 11, width: 28, height: 24)
        refreshButton.frame = NSRect(x: cardView.bounds.width - 42, y: 11, width: 28, height: 24)

        layoutCalendar()
    }

    func bind(viewModel: CalendarViewModel) {
        self.viewModel = viewModel
        render()
    }

    @objc private func showPreviousMonth() {
        guard let next = Calendar.current.date(byAdding: .month, value: -1, to: displayedMonthDate) else { return }
        displayedMonthDate = next
        render()
    }

    @objc private func showNextMonth() {
        guard let next = Calendar.current.date(byAdding: .month, value: 1, to: displayedMonthDate) else { return }
        displayedMonthDate = next
        render()
    }

    @objc private func refreshTapped() {
        guard let viewModel else { return }
        Task {
            await viewModel.refreshTapped()
            render()
        }
    }

    @objc private func settingsTapped() {
        onSettingsTapped?()
    }

    private func buildStaticCalendar() {
        let weekdays = ["一", "二", "三", "四", "五", "六", "日"]
        weekdayLabels = weekdays.map { text in
            let label = NSTextField(labelWithString: text)
            label.alignment = .center
            label.font = .systemFont(ofSize: 12, weight: .semibold)
            cardView.addSubview(label)
            return label
        }

        for _ in 0..<42 {
            let cell = StyledDayCellView(frame: .zero)
            cardView.addSubview(cell)
            dayCells.append(cell)
        }
    }

    private func layoutCalendar() {
        let horizontalPadding: CGFloat = 14
        let weekdayTopY = headerView.frame.minY - 30
        let gridTopY = weekdayTopY - 8
        let gridBottomY = footerView.frame.maxY + 8
        let usableWidth = cardView.bounds.width - horizontalPadding * 2
        let colWidth = usableWidth / 7
        let availableGridHeight = max(gridTopY - gridBottomY, 180)
        let weeks = max(weeksInDisplayedMonth(), 1)
        let rowHeight = max(floor(availableGridHeight / CGFloat(weeks)), 38)
        let cellWidth = max(colWidth - 8, 38)
        let cellHeight = max(rowHeight - 6, 38)

        for (index, label) in weekdayLabels.enumerated() {
            label.frame = NSRect(x: horizontalPadding + CGFloat(index) * colWidth, y: weekdayTopY, width: colWidth, height: 18)
        }

        for (index, cell) in dayCells.enumerated() {
            let row = index / 7
            let col = index % 7
            if row >= weeks {
                cell.isHidden = true
                continue
            }
            cell.isHidden = false
            cell.frame = NSRect(
                x: horizontalPadding + CGFloat(col) * colWidth + (colWidth - cellWidth) / 2,
                y: gridTopY - CGFloat(row + 1) * rowHeight,
                width: cellWidth,
                height: cellHeight
            )
        }
    }

    private func weeksInDisplayedMonth() -> Int {
        let calendar = Calendar(identifier: .gregorian)
        let monthStart = calendar.date(from: calendar.dateComponents([.year, .month], from: displayedMonthDate)) ?? displayedMonthDate
        let dayCount = calendar.range(of: .day, in: .month, for: monthStart)?.count ?? 30
        let weekday = calendar.component(.weekday, from: monthStart)
        let mondayFirstOffset = (weekday + 5) % 7
        return Int(ceil(Double(mondayFirstOffset + dayCount) / 7.0))
    }

    private func render() {
        refreshButton.isEnabled = viewModel?.isRefreshEnabled ?? true
        markerByDate = (viewModel?.holidayRecords ?? []).reduce(into: [:]) { partial, record in
            partial[record.date] = record.isHoliday ? .holiday : .makeupWorkday
        }

        let titleFormatter = DateFormatter()
        titleFormatter.locale = Locale(identifier: "zh_CN")
        titleFormatter.dateFormat = "yyyy年M月"
        monthTitleLabel.stringValue = titleFormatter.string(from: displayedMonthDate)

        applyDayStyles()
        applyThemeAndRender()
        needsLayout = true

        _ = holidayDateMatcher
    }

    private func applyDayStyles() {
        dayCellByDay.removeAll()

        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = .current

        let monthStart = calendar.date(from: calendar.dateComponents([.year, .month], from: displayedMonthDate)) ?? displayedMonthDate
        let dayCount = calendar.range(of: .day, in: .month, for: monthStart)?.count ?? 30

        let weekday = calendar.component(.weekday, from: monthStart)
        let mondayFirstOffset = (weekday + 5) % 7
        let todayComps = calendar.dateComponents([.year, .month, .day], from: Date())
        let monthComps = calendar.dateComponents([.year, .month], from: monthStart)

        let theme = CalendarTheme.current(for: effectiveAppearance)

        for index in 0..<dayCells.count {
            let slot = index - mondayFirstOffset + 1
            if slot < 1 || slot > dayCount {
                dayCells[index].configure(
                    day: nil,
                    isToday: false,
                    isWeekend: false,
                    markerType: .none,
                    festivalText: nil,
                    lunarText: "",
                    theme: theme
                )
                continue
            }

            let col = index % 7
            let isWeekend = col == 5 || col == 6
            let dateString = String(format: "%04d-%02d-%02d", monthComps.year ?? 1970, monthComps.month ?? 1, slot)
            let currentDate = calendar.date(from: DateComponents(year: monthComps.year, month: monthComps.month, day: slot)) ?? monthStart
            var markerType = markerByDate[dateString] ?? .none
            if markerType == .makeupWorkday && !isWeekend {
                markerType = .none
            }
            let isToday = todayComps.year == monthComps.year && todayComps.month == monthComps.month && todayComps.day == slot
            let festivalText = CalendarAnnotations.festivalText(for: currentDate)
            let lunarText = CalendarAnnotations.lunarText(for: currentDate)

            dayCells[index].configure(
                day: slot,
                isToday: isToday,
                isWeekend: isWeekend,
                markerType: markerType,
                festivalText: festivalText,
                lunarText: lunarText,
                theme: theme
            )
            dayCellByDay[slot] = dayCells[index]
        }
    }

    private func applyThemeAndRender() {
        let theme = CalendarTheme.current(for: effectiveAppearance)

        layer?.backgroundColor = theme.background.cgColor

        cardView.layer?.backgroundColor = theme.cardBackground.cgColor
        cardView.layer?.borderColor = theme.border.cgColor
        cardView.layer?.borderWidth = 1

        footerView.layer?.backgroundColor = theme.footerBackground.cgColor
        monthTitleLabel.textColor = theme.headerText

        prevButton.contentTintColor = theme.secondaryIcon
        nextButton.contentTintColor = theme.secondaryIcon
        settingsButton.contentTintColor = theme.secondaryIcon
        refreshButton.contentTintColor = theme.secondaryIcon

        for (index, label) in weekdayLabels.enumerated() {
            label.textColor = (index == 5 || index == 6) ? theme.primary : theme.weekText
        }
    }

    var renderedDayCountForTest: Int {
        dayCellByDay.count
    }

    func weekdayHeaderColorForTest(column: Int) -> NSColor? {
        guard weekdayLabels.indices.contains(column) else { return nil }
        return weekdayLabels[column].textColor
    }

    func dayLabelTextForTest(day: Int) -> String {
        dayCellByDay[day]?.debugText ?? ""
    }

    func lunarTextForTest(day: Int) -> String {
        dayCellByDay[day]?.debugLunarText ?? ""
    }

    func festivalTextForTest(day: Int) -> String {
        dayCellByDay[day]?.debugFestivalText ?? ""
    }

    func cornerTagTextForTest(day: Int) -> String {
        dayCellByDay[day]?.debugCornerTagText ?? ""
    }

    func dayNumberColorForTest(day: Int) -> NSColor? {
        dayCellByDay[day]?.debugNumberColor
    }

    func setDisplayedMonthForTest(_ date: Date) {
        displayedMonthDate = date
        render()
    }

    func applyHolidayRecordsForTest(_ records: [HolidayRecord]) {
        markerByDate = records.reduce(into: [:]) { partial, record in
            partial[record.date] = record.isHoliday ? .holiday : .makeupWorkday
        }
        applyDayStyles()
    }
}
