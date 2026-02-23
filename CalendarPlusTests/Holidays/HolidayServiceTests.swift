import XCTest
@testable import CalendarPlus

final class HolidayServiceTests: XCTestCase {
    func test_refresh_returns_records_and_marks_holiday_dates() async throws {
        let client = MockHolidayAPIClient(responseJSON: """
        [{"date":"2026-02-17","isHoliday":true,"name":"春节"}]
        """)
        let service = HolidayService(apiClient: client, cacheStore: MockHolidayCacheStore())
        let records = try await service.refresh(year: 2026)
        XCTAssertEqual(records.first?.date, "2026-02-17")
        XCTAssertEqual(records.first?.isHoliday, true)
    }
}

private struct MockHolidayAPIClient: HolidayAPIClient {
    let responseJSON: String

    func fetchHolidays(year: Int) async throws -> String {
        responseJSON
    }
}

private final class MockHolidayCacheStore: HolidayCacheStoreProtocol {
    func load(year: Int) throws -> [HolidayRecord] { [] }
    func save(records: [HolidayRecord], year: Int) throws {}
}
