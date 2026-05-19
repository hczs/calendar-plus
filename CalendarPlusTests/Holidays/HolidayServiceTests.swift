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

    func test_refresh_parses_timor_api_shape() async throws {
        let client = MockHolidayAPIClient(responseJSON: """
        {
          "code": 0,
          "holiday": {
            "2026-02-17": {"holiday": true, "name": "春节"},
            "2026-02-18": {"holiday": false, "name": null}
          }
        }
        """)
        let service = HolidayService(apiClient: client, cacheStore: MockHolidayCacheStore())
        let records = try await service.refresh(year: 2026)
        XCTAssertEqual(records.count, 2)
        XCTAssertEqual(records.first(where: { $0.date == "2026-02-17" })?.isHoliday, true)
    }

    func test_refresh_throws_for_unsupported_json_shape() async {
        let client = MockHolidayAPIClient(responseJSON: "{\"unexpected\":true}")
        let service = HolidayService(apiClient: client, cacheStore: MockHolidayCacheStore())

        do {
            _ = try await service.refresh(year: 2026)
            XCTFail("应抛出解析错误")
        } catch {
            XCTAssertNotNil(error)
        }
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
