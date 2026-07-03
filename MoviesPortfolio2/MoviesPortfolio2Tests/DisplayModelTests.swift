import XCTest
@testable import MoviesPortfolio2
import MoviesCore

@MainActor
final class DisplayModelTests: XCTestCase {
  func testMediaItemDisplayModelMapsMovieFields() {
    let model = MediaItemDisplayModel(movie: TestModelFactory.fightClub, isFavorite: true)

    XCTAssertEqual(model.id, 550)
    XCTAssertEqual(model.title, "Fight Club")
    XCTAssertEqual(model.overview, TestModelFactory.fightClub.overview)
    XCTAssertEqual(model.posterPath, TestModelFactory.fightClub.posterPath)
    XCTAssertTrue(model.isFavorite)

    let roundTrip = model.asMovie()
    XCTAssertEqual(roundTrip.id, 550)
    XCTAssertEqual(roundTrip.title, "Fight Club")
  }

  func testSearchResultDisplayModelMapsMovieAndTV() {
    let movie = SearchResultDisplayModel(movie: TestModelFactory.fightClub)
    XCTAssertEqual(movie.kind, .movie)
    XCTAssertEqual(movie.title, "Fight Club")

    let series = SearchResultDisplayModel(series: TestModelFactory.breakingBad)
    XCTAssertEqual(series.kind, .tv)
    XCTAssertEqual(series.title, "Breaking Bad")

    let mediaItem = movie.asMediaItem()
    XCTAssertEqual(mediaItem.id, movie.id)
    XCTAssertEqual(mediaItem.title, movie.title)
  }

  func testMovieDetailsDisplayModelFormatsMetadata() {
    let model = MovieDetailsDisplayModel(
      details: TestModelFactory.fightClubDetails,
      credits: TestModelFactory.fightClubCredits
    )

    XCTAssertEqual(model.title, "Fight Club")
    XCTAssertEqual(model.ratingText, "8.4")
    XCTAssertEqual(model.runtimeText, "2h 19m")
    XCTAssertEqual(model.tagline, "Mischief. Mayhem. Soap.")
    XCTAssertEqual(model.genres, ["Drama"])
    XCTAssertEqual(model.directors, ["David Fincher"])
    XCTAssertEqual(model.cast.map(\.name), ["Edward Norton", "Brad Pitt"])
    XCTAssertEqual(model.cast.first?.role, "The Narrator")
  }

  func testMovieDetailsDisplayModelOmitsEmptyTagline() {
    let details = MovieDetails(
      id: 1,
      title: "Test",
      overview: "Overview",
      posterPath: nil,
      backdropPath: nil,
      voteAverage: 7.0,
      voteCount: 100,
      releaseDate: nil,
      runtime: 45,
      tagline: "",
      status: "Released",
      genres: []
    )
    let model = MovieDetailsDisplayModel(details: details, credits: Credits(cast: [], crew: []))

    XCTAssertNil(model.tagline)
    XCTAssertEqual(model.runtimeText, "45m")
  }
}
