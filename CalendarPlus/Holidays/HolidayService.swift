import Foundation

protocol HolidayCacheStoreProtocol {
    func load(year: Int) throws -> [HolidayRecord]
    func save(records: [HolidayRecord], year: Int) throws
}

final class HolidayService {
    private let apiClient: HolidayAPIClient
    private let cacheStore: HolidayCacheStoreProtocol

    init(apiClient: HolidayAPIClient, cacheStore: HolidayCacheStoreProtocol) {
        self.apiClient = apiClient
        self.cacheStore = cacheStore
    }

    func refresh(year: Int) async throws -> [HolidayRecord] {
        do {
            let json = try await apiClient.fetchHolidays(year: year)
            let data = Data(json.utf8)
            let records = try JSONDecoder().decode([HolidayRecord].self, from: data)
            try cacheStore.save(records: records, year: year)
            return records
        } catch {
            throw error
        }
    }
}
