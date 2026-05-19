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

    func test_status_icon_mode_change_posts_notification() {
        let defaults = UserDefaults(suiteName: "SettingsStoreNotificationTests")!
        defaults.removePersistentDomain(forName: "SettingsStoreNotificationTests")
        let store = SettingsStore(userDefaults: defaults)
        let expectation = expectation(description: "settings changed")
        let token = NotificationCenter.default.addObserver(
            forName: .settingsStoreDidChange,
            object: store,
            queue: nil
        ) { _ in expectation.fulfill() }

        store.statusIconMode = .todayDate
        wait(for: [expectation], timeout: 1)
        NotificationCenter.default.removeObserver(token)
    }
}
