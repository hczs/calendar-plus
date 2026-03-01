import XCTest
@testable import CalendarPlus

final class SettingsFlowTests: XCTestCase {
    @MainActor
    func test_show_settings_page_switches_from_calendar_to_settings() {
        let defaults = UserDefaults(suiteName: "SettingsFlowTests")!
        defaults.removePersistentDomain(forName: "SettingsFlowTests")
        let store = SettingsStore(userDefaults: defaults)

        let sut = CalendarRootViewController(settingsStore: store)
        sut.loadViewIfNeeded()

        XCTAssertFalse(sut.isShowingSettingsForTest)
        sut.showSettingsForTest()
        XCTAssertTrue(sut.isShowingSettingsForTest)
    }

    @MainActor
    func test_select_theme_updates_store_and_view_appearance() {
        let defaults = UserDefaults(suiteName: "SettingsThemeFlowTests")!
        defaults.removePersistentDomain(forName: "SettingsThemeFlowTests")
        let store = SettingsStore(userDefaults: defaults)

        let sut = CalendarRootViewController(settingsStore: store)
        sut.loadViewIfNeeded()

        sut.selectThemeForTest(.dark)

        XCTAssertEqual(store.themeMode, .dark)
        XCTAssertEqual(sut.appearanceNameForTest, NSAppearance.Name.darkAqua)
    }
}
