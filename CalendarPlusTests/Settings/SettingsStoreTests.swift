import XCTest
@testable import CalendarPlus

final class SettingsStoreTests: XCTestCase {
    func test_settings_store_persists_status_icon_mode() {
        let store = SettingsStore(userDefaults: UserDefaults(suiteName: "SettingsStoreTests")!)
        store.statusIconMode = .todayDate
        XCTAssertEqual(store.statusIconMode, .todayDate)
    }
}
