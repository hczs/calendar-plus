# Mac Menu Bar Calendar (Lightweight) Implementation Plan

> **For Claude:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task.

**Goal:** Build a lightweight macOS menu bar calendar app (AppKit) that shows Chinese holiday markers (`假`), performs first-run holiday download with local cache, and supports manual refresh.

**Architecture:** Use `NSStatusItem` + `NSPopover` as the app shell, with isolated services for holiday fetching, cache persistence, and settings persistence. Keep UI and data layers decoupled so the month grid can render even when network is unavailable. Use annual JSON cache files in Application Support and an explicit refresh action.

**Tech Stack:** Swift, AppKit, Foundation, XCTest, xcodebuild

---

### Task 1: Bootstrap Minimal AppKit Menu Bar Project

**Files:**
- Create: `CalendarPlus.xcodeproj` (new macOS App project)
- Create: `CalendarPlus/AppDelegate.swift`
- Create: `CalendarPlus/Info.plist`
- Create: `CalendarPlus/Assets.xcassets`
- Test: `CalendarPlusTests/BootstrapTests.swift`

**Step 1: Write the failing test**

```swift
import XCTest
@testable import CalendarPlus

final class BootstrapTests: XCTestCase {
    func test_app_bootstraps_status_bar_controller() {
        let app = AppDelegate()
        XCTAssertNotNil(app.makeStatusBarControllerForTest())
    }
}
```

**Step 2: Run test to verify it fails**

Run: `xcodebuild test -scheme CalendarPlus -destination 'platform=macOS' -only-testing:CalendarPlusTests/BootstrapTests/test_app_bootstraps_status_bar_controller`
Expected: FAIL because `makeStatusBarControllerForTest` does not exist.

**Step 3: Write minimal implementation**

```swift
final class AppDelegate: NSObject, NSApplicationDelegate {
    private var statusBarController: StatusBarController?

    func applicationDidFinishLaunching(_ notification: Notification) {
        statusBarController = StatusBarController()
    }

    func makeStatusBarControllerForTest() -> StatusBarController {
        StatusBarController()
    }
}
```

**Step 4: Run test to verify it passes**

Run: same as Step 2
Expected: PASS

**Step 5: Commit**

```bash
git add CalendarPlus.xcodeproj CalendarPlus CalendarPlusTests
git commit -m "chore: bootstrap minimal appkit menubar app"
```

### Task 2: Implement Status Item + Popover Shell

**Files:**
- Create: `CalendarPlus/UI/StatusBarController.swift`
- Create: `CalendarPlus/UI/PopoverController.swift`
- Create: `CalendarPlus/UI/CalendarRootViewController.swift`
- Test: `CalendarPlusTests/UI/StatusBarControllerTests.swift`

**Step 1: Write the failing test**

```swift
func test_status_bar_controller_creates_button_and_popover() {
    let sut = StatusBarController()
    XCTAssertNotNil(sut.statusItem.button)
    XCTAssertNotNil(sut.popoverController)
}
```

**Step 2: Run test to verify it fails**

Run: `xcodebuild test -scheme CalendarPlus -destination 'platform=macOS' -only-testing:CalendarPlusTests/UI/StatusBarControllerTests/test_status_bar_controller_creates_button_and_popover`
Expected: FAIL because types/properties are missing.

**Step 3: Write minimal implementation**

```swift
final class StatusBarController {
    let statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
    let popoverController = PopoverController()

    init() {
        statusItem.button?.title = "📅"
        statusItem.button?.target = self
        statusItem.button?.action = #selector(togglePopover)
    }

    @objc private func togglePopover() { popoverController.toggle(relativeTo: statusItem.button) }
}
```

**Step 4: Run test to verify it passes**

Run: same as Step 2
Expected: PASS

**Step 5: Commit**

```bash
git add CalendarPlus/UI CalendarPlusTests/UI
git commit -m "feat: add status item and popover shell"
```

### Task 3: Build Month Grid UI with Holiday Marker Placeholder

**Files:**
- Create: `CalendarPlus/UI/MonthGrid/MonthGridView.swift`
- Create: `CalendarPlus/UI/MonthGrid/DayCellView.swift`
- Modify: `CalendarPlus/UI/CalendarRootViewController.swift`
- Test: `CalendarPlusTests/UI/MonthGridViewModelTests.swift`

**Step 1: Write the failing test**

```swift
func test_day_cell_shows_holiday_badge_when_isHoliday_true() {
    let vm = DayCellViewModel(day: 1, isToday: false, isSelected: false, isHoliday: true)
    XCTAssertEqual(vm.badgeText, "假")
}
```

**Step 2: Run test to verify it fails**

Run: `xcodebuild test -scheme CalendarPlus -destination 'platform=macOS' -only-testing:CalendarPlusTests/UI/MonthGridViewModelTests/test_day_cell_shows_holiday_badge_when_isHoliday_true`
Expected: FAIL because `DayCellViewModel` is missing.

**Step 3: Write minimal implementation**

```swift
struct DayCellViewModel {
    let day: Int
    let isToday: Bool
    let isSelected: Bool
    let isHoliday: Bool

    var badgeText: String? { isHoliday ? "假" : nil }
}
```

**Step 4: Run test to verify it passes**

Run: same as Step 2
Expected: PASS

**Step 5: Commit**

```bash
git add CalendarPlus/UI/MonthGrid CalendarPlus/UI/CalendarRootViewController.swift CalendarPlusTests/UI
git commit -m "feat: render month grid and holiday badge"
```

### Task 4: Add Settings for Menu Bar Display Mode

**Files:**
- Create: `CalendarPlus/Settings/SettingsStore.swift`
- Modify: `CalendarPlus/UI/StatusBarController.swift`
- Create: `CalendarPlus/UI/SettingsViewController.swift`
- Test: `CalendarPlusTests/Settings/SettingsStoreTests.swift`

**Step 1: Write the failing test**

```swift
func test_settings_store_persists_status_icon_mode() {
    let store = SettingsStore(userDefaults: UserDefaults(suiteName: "SettingsStoreTests")!)
    store.statusIconMode = .todayDate
    XCTAssertEqual(store.statusIconMode, .todayDate)
}
```

**Step 2: Run test to verify it fails**

Run: `xcodebuild test -scheme CalendarPlus -destination 'platform=macOS' -only-testing:CalendarPlusTests/Settings/SettingsStoreTests/test_settings_store_persists_status_icon_mode`
Expected: FAIL because store/mode types are missing.

**Step 3: Write minimal implementation**

```swift
enum StatusIconMode: String { case fixedIcon, todayDate }

final class SettingsStore {
    private let userDefaults: UserDefaults
    private let key = "statusIconMode"

    init(userDefaults: UserDefaults = .standard) { self.userDefaults = userDefaults }

    var statusIconMode: StatusIconMode {
        get { StatusIconMode(rawValue: userDefaults.string(forKey: key) ?? "fixedIcon") ?? .fixedIcon }
        set { userDefaults.set(newValue.rawValue, forKey: key) }
    }
}
```

**Step 4: Run test to verify it passes**

Run: same as Step 2
Expected: PASS

**Step 5: Commit**

```bash
git add CalendarPlus/Settings CalendarPlus/UI/StatusBarController.swift CalendarPlus/UI/SettingsViewController.swift CalendarPlusTests/Settings
git commit -m "feat: add menu bar display mode setting"
```

### Task 5: Implement Holiday Fetch Service (First-Run + Manual Refresh)

**Files:**
- Create: `CalendarPlus/Holidays/HolidayRecord.swift`
- Create: `CalendarPlus/Holidays/HolidayService.swift`
- Create: `CalendarPlus/Holidays/HolidayAPIClient.swift`
- Modify: `CalendarPlus/UI/CalendarRootViewController.swift`
- Test: `CalendarPlusTests/Holidays/HolidayServiceTests.swift`

**Step 1: Write the failing test**

```swift
func test_refresh_returns_records_and_marks_holiday_dates() async throws {
    let client = MockHolidayAPIClient(responseJSON: """
    [{"date":"2026-02-17","isHoliday":true,"name":"春节"}]
    """)
    let service = HolidayService(apiClient: client, cacheStore: MockHolidayCacheStore())
    let records = try await service.refresh(year: 2026)
    XCTAssertEqual(records.first?.date, "2026-02-17")
    XCTAssertEqual(records.first?.isHoliday, true)
}
```

**Step 2: Run test to verify it fails**

Run: `xcodebuild test -scheme CalendarPlus -destination 'platform=macOS' -only-testing:CalendarPlusTests/Holidays/HolidayServiceTests/test_refresh_returns_records_and_marks_holiday_dates`
Expected: FAIL because holiday service types are missing.

**Step 3: Write minimal implementation**

```swift
struct HolidayRecord: Codable {
    let date: String
    let isHoliday: Bool
    let name: String?
}

final class HolidayService {
    func refresh(year: Int) async throws -> [HolidayRecord] {
        // Fetch + decode + return
    }
}
```

**Step 4: Run test to verify it passes**

Run: same as Step 2
Expected: PASS

**Step 5: Commit**

```bash
git add CalendarPlus/Holidays CalendarPlus/UI/CalendarRootViewController.swift CalendarPlusTests/Holidays
git commit -m "feat: add holiday fetch service and refresh flow"
```

### Task 6: Add Local Annual Cache Store with Fallback Rules

**Files:**
- Create: `CalendarPlus/Holidays/HolidayCacheStore.swift`
- Modify: `CalendarPlus/Holidays/HolidayService.swift`
- Test: `CalendarPlusTests/Holidays/HolidayCacheStoreTests.swift`

**Step 1: Write the failing test**

```swift
func test_refresh_failure_keeps_previous_cache() async throws {
    let cache = HolidayCacheStore(fileManager: .default)
    try cache.save(records: [HolidayRecord(date: "2026-02-17", isHoliday: true, name: nil)], year: 2026)

    let service = HolidayService(apiClient: FailingAPIClient(), cacheStore: cache)
    do {
        _ = try await service.refresh(year: 2026)
        XCTFail("Expected throw")
    } catch {
        let cached = try cache.load(year: 2026)
        XCTAssertEqual(cached.count, 1)
    }
}
```

**Step 2: Run test to verify it fails**

Run: `xcodebuild test -scheme CalendarPlus -destination 'platform=macOS' -only-testing:CalendarPlusTests/Holidays/HolidayCacheStoreTests/test_refresh_failure_keeps_previous_cache`
Expected: FAIL because cache store methods are missing.

**Step 3: Write minimal implementation**

```swift
final class HolidayCacheStore {
    func load(year: Int) throws -> [HolidayRecord] { [] }
    func save(records: [HolidayRecord], year: Int) throws {}
}
```

**Step 4: Run test to verify it passes**

Run: same as Step 2
Expected: PASS

**Step 5: Commit**

```bash
git add CalendarPlus/Holidays/HolidayCacheStore.swift CalendarPlus/Holidays/HolidayService.swift CalendarPlusTests/Holidays
git commit -m "feat: add annual holiday cache with fallback behavior"
```

### Task 7: Wire Refresh Button + Non-Blocking Error/Success Messaging

**Files:**
- Modify: `CalendarPlus/UI/CalendarRootViewController.swift`
- Modify: `CalendarPlus/UI/MonthGrid/MonthGridView.swift`
- Test: `CalendarPlusTests/UI/RefreshFlowTests.swift`

**Step 1: Write the failing test**

```swift
func test_refresh_button_disables_while_loading_and_reenables() async {
    let vm = CalendarViewModel(service: DelayedHolidayService())
    XCTAssertTrue(vm.isRefreshEnabled)
    await vm.refreshTapped()
    XCTAssertTrue(vm.isRefreshEnabled)
}
```

**Step 2: Run test to verify it fails**

Run: `xcodebuild test -scheme CalendarPlus -destination 'platform=macOS' -only-testing:CalendarPlusTests/UI/RefreshFlowTests/test_refresh_button_disables_while_loading_and_reenables`
Expected: FAIL because view model state is missing.

**Step 3: Write minimal implementation**

```swift
@MainActor
final class CalendarViewModel {
    private(set) var isRefreshEnabled = true

    func refreshTapped() async {
        isRefreshEnabled = false
        defer { isRefreshEnabled = true }
        // call service + publish result message
    }
}
```

**Step 4: Run test to verify it passes**

Run: same as Step 2
Expected: PASS

**Step 5: Commit**

```bash
git add CalendarPlus/UI CalendarPlusTests/UI/RefreshFlowTests.swift
git commit -m "feat: add refresh button loading and message state"
```

### Task 8: Add Timezone Rules and Regression Tests

**Files:**
- Create: `CalendarPlus/Holidays/HolidayDateMatcher.swift`
- Modify: `CalendarPlus/UI/MonthGrid/MonthGridView.swift`
- Test: `CalendarPlusTests/Holidays/HolidayDateMatcherTests.swift`

**Step 1: Write the failing test**

```swift
func test_holiday_match_uses_asia_shanghai_calendar_day() {
    let matcher = HolidayDateMatcher(timeZoneID: "Asia/Shanghai")
    let date = ISO8601DateFormatter().date(from: "2026-02-16T16:30:00Z")!
    XCTAssertTrue(matcher.matches(date: date, holidayDateString: "2026-02-17"))
}
```

**Step 2: Run test to verify it fails**

Run: `xcodebuild test -scheme CalendarPlus -destination 'platform=macOS' -only-testing:CalendarPlusTests/Holidays/HolidayDateMatcherTests/test_holiday_match_uses_asia_shanghai_calendar_day`
Expected: FAIL because matcher is missing.

**Step 3: Write minimal implementation**

```swift
struct HolidayDateMatcher {
    let calendar: Calendar

    init(timeZoneID: String = "Asia/Shanghai") {
        var cal = Calendar(identifier: .gregorian)
        cal.timeZone = TimeZone(identifier: timeZoneID) ?? .current
        self.calendar = cal
    }
}
```

**Step 4: Run test to verify it passes**

Run: same as Step 2
Expected: PASS

**Step 5: Commit**

```bash
git add CalendarPlus/Holidays/HolidayDateMatcher.swift CalendarPlus/UI/MonthGrid/MonthGridView.swift CalendarPlusTests/Holidays
git commit -m "test: enforce asia shanghai holiday matching"
```

### Task 9: QA Checklist + Lightweight Performance Sanity

**Files:**
- Create: `docs/testing/manual-qa-menubar-calendar.md`
- Modify: `README.md`

**Step 1: Write the failing test**

```text
N/A (manual QA documentation task)
```

**Step 2: Run verification command (expected to fail initially due to missing doc)**

Run: `test -f docs/testing/manual-qa-menubar-calendar.md`
Expected: non-zero exit before doc creation.

**Step 3: Write minimal implementation**

```markdown
- Verify popover opens from menubar click
- Verify holiday badge `假` appears on known holiday
- Verify refresh success/failure messaging
- Verify offline fallback with cache
- Verify icon mode switch persists after restart
```

**Step 4: Run verification command**

Run: `test -f docs/testing/manual-qa-menubar-calendar.md && echo OK`
Expected: `OK`

**Step 5: Commit**

```bash
git add docs/testing/manual-qa-menubar-calendar.md README.md
git commit -m "docs: add qa checklist and usage notes"
```

## Notes
- Keep all networking asynchronous and off the main thread.
- Avoid third-party dependencies unless strictly necessary.
- Prefer simple value types for day/holiday models to minimize memory overhead.
- If project is not yet a git repo, run `git init` before commit steps.
