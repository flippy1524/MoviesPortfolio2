import XCTest
@testable import MoviesCore

final class APIRequestBuilderTests: XCTestCase {
    func testTrendingURLIncludesAPIKeyAndPage() throws {
        let builder = APIRequestBuilder(configuration: MockAPIConfiguration.test)
        let url = try builder.url(for: .trendingMovies(page: 2))

        let components = URLComponents(url: url, resolvingAgainstBaseURL: false)
        let query = Dictionary(uniqueKeysWithValues: (components?.queryItems ?? []).map { ($0.name, $0.value) })

        XCTAssertTrue(url.path.hasSuffix("/trending/movie/day"))
        XCTAssertEqual(query["api_key"], "test-api-key")
        XCTAssertEqual(query["page"], "2")
    }

    func testSearchMoviesURLIncludesQuery() throws {
        let builder = APIRequestBuilder(configuration: MockAPIConfiguration.test)
        let url = try builder.url(for: .searchMovies(query: "matrix", page: 1))

        let components = URLComponents(url: url, resolvingAgainstBaseURL: false)
        let query = Dictionary(uniqueKeysWithValues: (components?.queryItems ?? []).map { ($0.name, $0.value) })

        XCTAssertTrue(url.path.hasSuffix("/search/movie"))
        XCTAssertEqual(query["query"], "matrix")
    }
}

final class URLSessionAPIClientTests: XCTestCase {
    private struct StubDataFetcher: URLDataFetching {
        let data: Data
        let response: HTTPURLResponse

        func data(for request: URLRequest) async throws -> (Data, URLResponse) {
            (data, response)
        }
    }

    func testTrendingRequestDecodesResponse() async throws {
        let fixture = try TestFixtures.data(named: "trending_movies")
        let url = try APIRequestBuilder(configuration: MockAPIConfiguration.test)
            .url(for: .trendingMovies(page: 1))

        let fetcher = StubDataFetcher(
            data: fixture,
            response: HTTPURLResponse(url: url, statusCode: 200, httpVersion: nil, headerFields: nil)!
        )

        let client = URLSessionAPIClient(
            configuration: MockAPIConfiguration.test,
            dataFetcher: fetcher
        )

        let result: PaginatedResponse<Movie> = try await client.request(.trendingMovies(page: 1))
        XCTAssertEqual(result.results.first?.id, 550)
    }

    func testHTTPStatusError() async throws {
        let url = try APIRequestBuilder(configuration: MockAPIConfiguration.test)
            .url(for: .trendingMovies(page: 1))

        let fetcher = StubDataFetcher(
            data: Data(),
            response: HTTPURLResponse(url: url, statusCode: 401, httpVersion: nil, headerFields: nil)!
        )

        let client = URLSessionAPIClient(
            configuration: MockAPIConfiguration.test,
            dataFetcher: fetcher
        )

        do {
            let _: PaginatedResponse<Movie> = try await client.request(.trendingMovies(page: 1))
            XCTFail("Expected http status error")
        } catch let error as NetworkError {
            XCTAssertEqual(error, .httpStatus(401))
        }
    }
}
