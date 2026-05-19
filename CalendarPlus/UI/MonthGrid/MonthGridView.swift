import AppKit

@MainActor
final class MonthGridView: NSView {
    private enum Layout {
        static let toolbarHeight: CGFloat = 44
        static let statusHeight: CGFloat = 18
        static let horizontalPadding: CGFloat = 12
        static let weekdayRowHeight: CGFloat = 18
        static let weekdayGapBelowToolbar: CGFloat = 6
        static let gridBottomInset: CGFloat = 10
        static let minCellSize: CGFloat = 36
        static let minGridHeight: CGFloat = 180
    }

    private let holidayDateMatcher = HolidayDateMatcher()
    private let calendar = CalendarGregorian.shanghai

    private static let monthTitleFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "zh_CN")
        formatter.timeZone = CalendarGregorian.shanghai.timeZone
        formatter.dateFormat = "yyyy年M月"
        return formatter
    }()

    private let toolbarView = NSView(frame: .zero)

    private let monthTitleLabel = NSTextField(labelWithString: "")
    private let statusMessageLabel = NSTextField(labelWithString: "")
    private let prevButton = NSButton(frame: .zero)
    private let nextButton = NSButton(frame: .zero)
    private let refreshButton = NSButton(frame: .zero)
    private let settingsButton = NSButton(frame: .zero)

    private var weekdayLabels: [NSTextField] = []
    private var dayCells: [StyledDayCellView] = []
    private var dayCellByDay: [Int: StyledDayCellView] = [:]

    private var viewModel: CalendarViewModel?
    private var testHolidayRecords: [HolidayRecord]?
    private var displayedMonthDate = Date()

    var onSettingsTapped: (() -> Void)?
    var onDisplayedMonthChanged: ((Date) -> Void)?

    override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
        wantsLayer = true

        toolbarView.wantsLayer = true
        addSubview(toolbarView)

        monthTitleLabel.font = .systemFont(ofSize: 17, weight: .semibold)
        monthTitleLabel.alignment = .center
        toolbarView.addSubview(monthTitleLabel)

        statusMessageLabel.font = .systemFont(ofSize: 11)
        statusMessageLabel.lineBreakMode = .byTruncatingTail
        addSubview(statusMessageLabel)

        configureIconButton(prevButton, symbol: "chevron.left", label: "上个月", action: #selector(showPreviousMonth))
        configureIconButton(nextButton, symbol: "chevron.right", label: "下个月", action: #selector(showNextMonth))
        configureIconButton(refreshButton, symbol: "arrow.clockwise", label: "刷新节假日", action: #selector(refreshTapped))
        configureIconButton(settingsButton, symbol: "gearshape", label: "打开设置", action: #selector(settingsTapped))

        toolbarView.addSubview(prevButton)
        toolbarView.addSubview(nextButton)
        toolbarView.addSubview(refreshButton)
        toolbarView.addSubview(settingsButton)

        buildStaticCalendar()
        render()
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidChangeEffectiveAppearance() {
        super.viewDidChangeEffectiveAppearance()
        render()
    }

    override func layout() {
        super.layout()

        let statusVisible = !statusMessageLabel.isHidden
        let statusBlockHeight = statusVisible ? Layout.statusHeight : 0

        toolbarView.frame = NSRect(
            x: 0,
            y: bounds.height - Layout.toolbarHeight,
            width: bounds.width,
            height: Layout.toolbarHeight
        )

        prevButton.frame = NSRect(x: Layout.horizontalPadding, y: 8, width: 30, height: 28)
        nextButton.frame = NSRect(x: Layout.horizontalPadding + 34, y: 8, width: 30, height: 28)
        settingsButton.frame = NSRect(x: toolbarView.bounds.width - Layout.horizontalPadding - 30, y: 8, width: 30, height: 28)
        refreshButton.frame = NSRect(x: toolbarView.bounds.width - Layout.horizontalPadding - 64, y: 8, width: 30, height: 28)

        let titleX = prevButton.frame.maxX + 8
        let titleMaxX = refreshButton.frame.minX - 8
        monthTitleLabel.frame = NSRect(
            x: titleX,
            y: 10,
            width: max(titleMaxX - titleX, 80),
            height: 24
        )

        if statusVisible {
            statusMessageLabel.frame = NSRect(
                x: Layout.horizontalPadding,
                y: toolbarView.frame.minY - statusBlockHeight,
                width: bounds.width - Layout.horizontalPadding * 2,
                height: Layout.statusHeight
            )
        }

        layoutCalendar(statusBottomY: toolbarView.frame.minY - statusBlockHeight)
    }

    func bind(viewModel: CalendarViewModel) {
        self.viewModel = viewModel
        render()
    }

    @objc private func showPreviousMonth() {
        changeDisplayedMonth(byAdding: -1)
    }

    @objc private func showNextMonth() {
        changeDisplayedMonth(byAdding: 1)
    }

    private func changeDisplayedMonth(byAdding months: Int) {
        guard let next = calendar.date(byAdding: .month, value: months, to: displayedMonthDate) else { return }
        displayedMonthDate = next
        onDisplayedMonthChanged?(displayedMonthDate)
        if viewModel == nil {
            render()
        }
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

    private func configureIconButton(_ button: NSButton, symbol: String, label: String, action: Selector) {
        button.bezelStyle = .accessoryBar
        button.isBordered = false
        button.image = NSImage(systemSymbolName: symbol, accessibilityDescription: label)
        button.imagePosition = .imageOnly
        button.toolTip = label
        button.target = self
        button.action = action
    }

    private func buildStaticCalendar() {
        let weekdays = ["一", "二", "三", "四", "五", "六", "日"]
        weekdayLabels = weekdays.map { text in
            let label = NSTextField(labelWithString: text)
            label.alignment = .center
            label.font = .systemFont(ofSize: 11, weight: .semibold)
            addSubview(label)
            return label
        }

        for _ in 0..<42 {
            let cell = StyledDayCellView(frame: .zero)
            addSubview(cell)
            dayCells.append(cell)
        }
    }

    private func layoutCalendar(statusBottomY: CGFloat) {
        let weekdayTopY = statusBottomY - Layout.weekdayGapBelowToolbar - Layout.weekdayRowHeight
        let gridTopY = weekdayTopY - Layout.weekdayRowHeight
        let gridBottomY = Layout.gridBottomInset
        let usableWidth = bounds.width - Layout.horizontalPadding * 2
        let colWidth = usableWidth / 7
        let availableGridHeight = max(gridTopY - gridBottomY, Layout.minGridHeight)
        let weeks = max(weeksInDisplayedMonth(), 1)
        let rowHeight = max(floor(availableGridHeight / CGFloat(weeks)), Layout.minCellSize)
        let cellWidth = max(colWidth - 6, Layout.minCellSize)
        let cellHeight = max(rowHeight - 4, Layout.minCellSize)

        for (index, label) in weekdayLabels.enumerated() {
            label.frame = NSRect(
                x: Layout.horizontalPadding + CGFloat(index) * colWidth,
                y: weekdayTopY,
                width: colWidth,
                height: Layout.weekdayRowHeight
            )
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
                x: Layout.horizontalPadding + CGFloat(col) * colWidth + (colWidth - cellWidth) / 2,
                y: gridTopY - CGFloat(row + 1) * rowHeight,
                width: cellWidth,
                height: cellHeight
            )
        }
    }

    private func weeksInDisplayedMonth() -> Int {
        let monthStart = calendar.date(from: calendar.dateComponents([.year, .month], from: displayedMonthDate)) ?? displayedMonthDate
        let dayCount = calendar.range(of: .day, in: .month, for: monthStart)?.count ?? 30
        let weekday = calendar.component(.weekday, from: monthStart)
        let mondayFirstOffset = (weekday + 5) % 7
        return Int(ceil(Double(mondayFirstOffset + dayCount) / 7.0))
    }

    private var holidayRecordsForDisplay: [HolidayRecord] {
        testHolidayRecords ?? viewModel?.holidayRecords ?? []
    }

    private func render() {
        refreshButton.isEnabled = viewModel?.isRefreshEnabled ?? true

        let message = viewModel?.message ?? ""
        statusMessageLabel.stringValue = message
        statusMessageLabel.isHidden = message.isEmpty

        monthTitleLabel.stringValue = Self.monthTitleFormatter.string(from: displayedMonthDate)

        applyAppearance()
        needsLayout = true
        layoutSubtreeIfNeeded()
    }

    private func applyAppearance() {
        let theme = CalendarTheme.current(for: effectiveAppearance)

        layer?.backgroundColor = theme.background.cgColor
        toolbarView.layer?.backgroundColor = theme.background.cgColor

        monthTitleLabel.textColor = theme.headerText
        statusMessageLabel.textColor = theme.weekText

        for button in [prevButton, nextButton, settingsButton, refreshButton] {
            button.contentTintColor = theme.secondaryIcon
        }

        for (index, label) in weekdayLabels.enumerated() {
            label.textColor = (index == 5 || index == 6) ? theme.primary : theme.weekText
        }

        applyDayCells(theme: theme)
    }

    private func applyDayCells(theme: CalendarTheme) {
        dayCellByDay.removeAll()

        let monthStart = calendar.date(from: calendar.dateComponents([.year, .month], from: displayedMonthDate)) ?? displayedMonthDate
        let dayCount = calendar.range(of: .day, in: .month, for: monthStart)?.count ?? 30

        let weekday = calendar.component(.weekday, from: monthStart)
        let mondayFirstOffset = (weekday + 5) % 7
        let todayComps = calendar.dateComponents([.year, .month, .day], from: Date())
        let monthComps = calendar.dateComponents([.year, .month], from: monthStart)
        let records = holidayRecordsForDisplay

        for index in 0..<dayCells.count {
            let slot = index - mondayFirstOffset + 1
            if slot < 1 || slot > dayCount {
                dayCells[index].configure(
                    day: nil,
                    date: nil,
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
            let currentDate = calendar.date(from: DateComponents(
                timeZone: calendar.timeZone,
                year: monthComps.year,
                month: monthComps.month,
                day: slot
            )) ?? monthStart

            var markerType: DayMarkerType = .none
            if let record = holidayDateMatcher.matchingRecord(for: currentDate, in: records) {
                markerType = record.isHoliday ? .holiday : .makeupWorkday
            }
            if markerType == .makeupWorkday && !isWeekend {
                markerType = .none
            }

            let isToday = todayComps.year == monthComps.year
                && todayComps.month == monthComps.month
                && todayComps.day == slot
            let festivalText = CalendarAnnotations.festivalText(for: currentDate)
            let lunarText = CalendarAnnotations.lunarText(for: currentDate)

            dayCells[index].configure(
                day: slot,
                date: currentDate,
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

    func dayDetailColorForTest(day: Int) -> NSColor? {
        dayCellByDay[day]?.debugDetailColor
    }

    func holidayTintAppliedForTest(day: Int) -> Bool {
        dayCellByDay[day]?.debugUsesHolidayTintForTest ?? false
    }

    var statusMessageForTest: String {
        statusMessageLabel.stringValue
    }

    func setDisplayedMonthForTest(_ date: Date) {
        displayedMonthDate = date
        onDisplayedMonthChanged?(date)
        if viewModel == nil {
            render()
        }
    }

    func applyHolidayRecordsForTest(_ records: [HolidayRecord]) {
        testHolidayRecords = records
        render()
    }
}
