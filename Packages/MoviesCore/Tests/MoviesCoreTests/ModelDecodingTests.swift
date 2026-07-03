import XCTest
@testable import MoviesCore

final class ModelDecodingTests: XCTestCase {
    func testTrendingMoviesDecoding() throws {
        let response: PaginatedResponse<Movie> = try TestFixtures.decode(
            PaginatedResponse<Movie>.self,
            from: "trending_movies"
        )

        XCTAssertEqual(response.page, 1)
        XCTAssertEqual(response.results.count, 1)
        XCTAssertEqual(response.results.first?.title, "Fight Club")
        XCTAssertEqual(response.results.first?.posterPath, "/pB8BM7pdDpEwFT5N9vrnGiJ6i0G.jpg")
    }

    func testMovieDetailsDecoding() throws {
        let details: MovieDetails = try TestFixtures.decode(MovieDetails.self, from: "movie_details")

        XCTAssertEqual(details.id, 550)
        XCTAssertEqual(details.runtime, 139)
        XCTAssertEqual(details.genres.first?.name, "Drama")
    }

    func testCreditsDecoding() throws {
        let credits: Credits = try TestFixtures.decode(Credits.self, from: "movie_credits")

        XCTAssertEqual(credits.cast.first?.name, "Edward Norton")
        XCTAssertEqual(credits.crew.first?.job, "Director")
    }

    func testPosterURLBuilder() {
        let url = ImageURLBuilder.posterURL(path: "/poster.jpg", size: .w342)
        XCTAssertEqual(url?.absoluteString, "https://image.tmdb.org/t/p/w342/poster.jpg")
    }

    func testPosterSizeForWidth() {
        XCTAssertEqual(ImageURLBuilder.posterSize(forWidth: 80), .w92)
        XCTAssertEqual(ImageURLBuilder.posterSize(forWidth: 500), .w500)
        XCTAssertEqual(ImageURLBuilder.posterSize(forWidth: 700), .w780)
    }
}
