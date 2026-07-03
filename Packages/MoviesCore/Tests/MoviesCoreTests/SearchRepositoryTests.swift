import XCTest
@testable import MoviesCore

final class SearchRepositoryTests: XCTestCase {
    private final class MockAPIClient: APIClient, @unchecked Sendable {
        private let handler: @Sendable (APIEndpoint) async throws -> Any

        init(handler: @escaping @Sendable (APIEndpoint) async throws -> Any) {
            self.handler = handler
        }

        func request<T: Decodable & Sendable>(_ endpoint: APIEndpoint) async throws -> T {
            guard let value = try await handler(endpoint) as? T else {
                throw NetworkError.invalidResponse
            }
            return value
        }
    }

    func testSearchMoviesUsesSearchEndpoint() async throws {
        let expected: PaginatedResponse<Movie> = try TestFixtures.decode(
            PaginatedResponse<Movie>.self,
            from: "search_movies"
        )

        let repository = LiveSearchRepository(client: MockAPIClient { endpoint in
            XCTAssertEqual(endpoint, .searchMovies(query: "matrix", page: 2))
            return expected
        })

        let result = try await repository.searchMovies(query: "matrix", page: 2)
        XCTAssertEqual(result.results.first?.title, "The Matrix")
    }

    func testSearchTVUsesSearchEndpoint() async throws {
        let expected: PaginatedResponse<TVSeries> = try TestFixtures.decode(
            PaginatedResponse<TVSeries>.self,
            from: "search_tv"
        )

        let repository = LiveSearchRepository(client: MockAPIClient { endpoint in
            XCTAssertEqual(endpoint, .searchTV(query: "breaking", page: 1))
            return expected
        })

        let result = try await repository.searchTV(query: "breaking", page: 1)
        XCTAssertEqual(result.results.first?.name, "Breaking Bad")
    }
}

final class APIEndpointTests: XCTestCase {
    func testMovieDetailsAndCreditsPaths() {
        XCTAssertEqual(APIEndpoint.movieDetails(id: 42).path, "/movie/42")
        XCTAssertEqual(APIEndpoint.movieCredits(id: 42).path, "/movie/42/credits")
    }

    func testSearchTVQueryItemsIncludeQueryAndPage() {
        let items = APIEndpoint.searchTV(query: "arcane", page: 4).queryItems(apiKey: "key")
        let query = Dictionary(uniqueKeysWithValues: items.map { ($0.name, $0.value) })

        XCTAssertEqual(query["api_key"], "key")
        XCTAssertEqual(query["query"], "arcane")
        XCTAssertEqual(query["page"], "4")
    }
}

final class ImageURLBuilderExtendedTests: XCTestCase {
    func testPosterURLsReturnsDistinctLowAndHighWhenSizesDiffer() {
        let urls = ImageURLBuilder.posterURLs(path: "/poster.jpg", layoutWidth: 500)

        XCTAssertEqual(urls.low?.absoluteString, "https://image.tmdb.org/t/p/w92/poster.jpg")
        XCTAssertEqual(urls.high?.absoluteString, "https://image.tmdb.org/t/p/w500/poster.jpg")
    }

    func testPosterURLsUsesSingleURLWhenLowMatchesHigh() {
        let urls = ImageURLBuilder.posterURLs(path: "/poster.jpg", layoutWidth: 80)

        XCTAssertEqual(urls.low, urls.high)
        XCTAssertEqual(urls.high?.absoluteString, "https://image.tmdb.org/t/p/w92/poster.jpg")
    }
}

final class NetworkErrorTests: XCTestCase {
    func testEqualityIgnoresUnderlyingErrorIdentity() {
        let left = NetworkError.decoding(DecodingError.dataCorrupted(.init(codingPath: [], debugDescription: "a")))
        let right = NetworkError.decoding(DecodingError.dataCorrupted(.init(codingPath: [], debugDescription: "b")))

        XCTAssertEqual(left, right)
        XCTAssertNotEqual(left, NetworkError.invalidURL)
    }
}
