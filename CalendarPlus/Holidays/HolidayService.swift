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
        let json = try await apiClient.fetchHolidays(year: year)
        let records = try parseRecords(json: json, year: year)
        try cacheStore.save(records: records, year: year)
        return records
    }

    func loadCached(year: Int) -> [HolidayRecord] {
        (try? cacheStore.load(year: year)) ?? []
    }

    private func parseRecords(json: String, year: Int) throws -> [HolidayRecord] {
        let data = Data(json.utf8)
        if let direct = try? JSONDecoder().decode([HolidayRecord].self, from: data) {
            return direct
        }

        let timor = try JSONDecoder().decode(TimorResponse.self, from: data)
        return timor.holiday.map { key, value in
            HolidayRecord(
                date: normalizedDateString(key, year: year),
                isHoliday: value.holiday ?? false,
                name: value.name
            )
        }.sorted { $0.date < $1.date }
    }

    private func normalizedDateString(_ raw: String, year: Int) -> String {
        if raw.count == 10 { return raw }
        if raw.count == 5 { return "\(year)-\(raw)" }
        return raw
    }
}

private struct TimorResponse: Decodable {
    let holiday: [String: TimorHoliday]
}

private struct TimorHoliday: Decodable {
    let holiday: Bool?
    let name: String?
}
