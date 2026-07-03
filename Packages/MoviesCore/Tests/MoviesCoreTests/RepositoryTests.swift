import XCTest
@testable import MoviesCore

final class RepositoryTests: XCTestCase {
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

    func testTrendingRepositoryUsesTrendingEndpoint() async throws {
        let expected: PaginatedResponse<Movie> = try TestFixtures.decode(
            PaginatedResponse<Movie>.self,
            from: "trending_movies"
        )

        let repository = LiveTrendingRepository(client: MockAPIClient { endpoint in
            XCTAssertEqual(endpoint, .trendingMovies(page: 3))
            return expected
        })

        let result = try await repository.fetchTrending(page: 3)
        XCTAssertEqual(result, expected)
    }

    func testMovieDetailsRepositoryFetchesDetailsAndCredits() async throws {
        let details: MovieDetails = try TestFixtures.decode(MovieDetails.self, from: "movie_details")
        let credits: Credits = try TestFixtures.decode(Credits.self, from: "movie_credits")

        let repository = LiveMovieDetailsRepository(client: MockAPIClient { endpoint in
            switch endpoint {
            case .movieDetails(id: 550):
                return details
            case .movieCredits(id: 550):
                return credits
            default:
                throw NetworkError.invalidResponse
            }
        })

        let fetchedDetails = try await repository.fetchMovieDetails(id: 550)
        let fetchedCredits = try await repository.fetchCredits(id: 550)

        XCTAssertEqual(fetchedDetails.title, "Fight Club")
        XCTAssertEqual(fetchedCredits.cast.first?.name, "Edward Norton")
    }
}
