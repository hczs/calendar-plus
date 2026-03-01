import XCTest
@testable import CalendarPlus

final class SettingsStoreTests: XCTestCase {
    func test_settings_store_persists_status_icon_mode() {
        let defaults = UserDefaults(suiteName: "SettingsStoreTests")!
        defaults.removePersistentDomain(forName: "SettingsStoreTests")
        let store = SettingsStore(userDefaults: defaults)
        store.statusIconMode = .todayDate
        XCTAssertEqual(store.statusIconMode, .todayDate)
    }

    func test_settings_store_persists_theme_mode() {
        let defaults = UserDefaults(suiteName: "SettingsStoreThemeTests")!
        defaults.removePersistentDomain(forName: "SettingsStoreThemeTests")
        let store = SettingsStore(userDefaults: defaults)
        store.themeMode = .dark
        XCTAssertEqual(store.themeMode, .dark)
    }
}
