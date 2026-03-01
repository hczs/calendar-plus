import Foundation

final class HolidayCacheStore: HolidayCacheStoreProtocol {
    private let fileManager: FileManager
    private let baseURL: URL

    init(fileManager: FileManager = .default, baseURL: URL? = nil) {
        self.fileManager = fileManager
        if let baseURL {
            self.baseURL = baseURL
        } else {
            let appSupport = fileManager.urls(for: .applicationSupportDirectory, in: .userDomainMask).first ?? URL(fileURLWithPath: NSTemporaryDirectory(), isDirectory: true)
            let bundleID = Bundle.main.bundleIdentifier ?? "CalendarPlus"
            self.baseURL = appSupport.appendingPathComponent(bundleID, isDirectory: true)
        }
    }

    func load(year: Int) throws -> [HolidayRecord] {
        let url = fileURL(for: year)
        guard fileManager.fileExists(atPath: url.path) else { return [] }
        let data = try Data(contentsOf: url)
        return try JSONDecoder().decode([HolidayRecord].self, from: data)
    }

    func save(records: [HolidayRecord], year: Int) throws {
        try fileManager.createDirectory(at: baseURL, withIntermediateDirectories: true)
        let data = try JSONEncoder().encode(records)
        try data.write(to: fileURL(for: year), options: .atomic)
    }

    private func fileURL(for year: Int) -> URL {
        baseURL.appendingPathComponent("holidays-\(year).json")
    }
}
