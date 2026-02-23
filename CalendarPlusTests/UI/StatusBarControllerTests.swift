import XCTest
@testable import CalendarPlus

final class StatusBarControllerTests: XCTestCase {
    func test_status_bar_controller_creates_button_and_popover() {
        MainActor.assumeIsolated {
            let sut = StatusBarController()
            XCTAssertNotNil(sut.statusItem.button)
            XCTAssertNotNil(sut.popoverController)
        }
    }
}
