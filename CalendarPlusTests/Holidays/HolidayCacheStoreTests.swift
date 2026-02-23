import XCTest
@testable import CalendarPlus

final class HolidayCacheStoreTests: XCTestCase {
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
}

private struct FailingAPIClient: HolidayAPIClient {
    func fetchHolidays(year: Int) async throws -> String {
        throw URLError(.notConnectedToInternet)
    }
}
