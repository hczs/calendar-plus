import XCTest
@testable import CalendarPlus

final class BootstrapTests: XCTestCase {
    func test_app_delegate_can_be_created() {
        MainActor.assumeIsolated {
            let app = AppDelegate()
            XCTAssertNotNil(app)
        }
    }
}
