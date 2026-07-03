import Foundation

public struct PaginatedResponse<T: Codable & Sendable & Equatable>: Codable, Sendable, Equatable {
    public let page: Int
    public let results: [T]
    public let totalPages: Int
    public let totalResults: Int

    enum CodingKeys: String, CodingKey {
        case page
        case results
        case totalPages = "total_pages"
        case totalResults = "total_results"
    }

    public init(page: Int, results: [T], totalPages: Int, totalResults: Int) {
        self.page = page
        self.results = results
        self.totalPages = totalPages
        self.totalResults = totalResults
    }
}
