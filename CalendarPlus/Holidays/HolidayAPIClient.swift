import Foundation

protocol HolidayAPIClient {
    func fetchHolidays(year: Int) async throws -> String
}

struct URLSessionHolidayAPIClient: HolidayAPIClient {
    func fetchHolidays(year: Int) async throws -> String {
        guard let url = URL(string: "https://timor.tech/api/holiday/year/\(year)") else {
            throw URLError(.badURL)
        }

        let (data, response) = try await URLSession.shared.data(from: url)
        guard let http = response as? HTTPURLResponse else {
            throw URLError(.badServerResponse)
        }
        guard (200 ... 299).contains(http.statusCode) else {
            throw URLError(.badServerResponse)
        }
        guard let json = String(data: data, encoding: .utf8) else {
            throw URLError(.cannotDecodeContentData)
        }
        return json
    }
}
