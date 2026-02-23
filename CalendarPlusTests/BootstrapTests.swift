import XCTest
@testable import CalendarPlus

final class BootstrapTests: XCTestCase {
    func test_app_bootstraps_status_bar_controller() {
        MainActor.assumeIsolated {
            let app = AppDelegate()
            XCTAssertNotNil(app.makeStatusBarControllerForTest())
        }
    }
}
