import XCTest
@testable import MoviesPortfolio2
import MoviesCore

@MainActor
final class FavoritesRepositoryTests: XCTestCase {
  func testToggleFavoriteAddsAndRemovesMovie() {
    let store = InMemoryFavoritesStore()
    let repository = FavoritesRepository(store: store)
    let item = MediaItemDisplayModel(movie: TestModelFactory.fightClub)

    repository.toggleFavorite(for: item)
    XCTAssertTrue(repository.isFavorite(movieID: 550))

    repository.toggleFavorite(for: item)
    XCTAssertFalse(repository.isFavorite(movieID: 550))
  }

  func testMarkFavoritesUpdatesDisplayModels() {
    let store = InMemoryFavoritesStore()
    try? store.addFavorite(from: TestModelFactory.fightClub)
    let repository = FavoritesRepository(store: store)

    let items = [
      MediaItemDisplayModel(movie: TestModelFactory.fightClub),
      MediaItemDisplayModel(movie: TestModelFactory.matrix)
    ]
    let marked = repository.markFavorites(in: items)

    XCTAssertTrue(marked[0].isFavorite)
    XCTAssertFalse(marked[1].isFavorite)
  }
}

@MainActor
final class UserFacingErrorMessageTests: XCTestCase {
  func testNetworkErrorMessages() {
    XCTAssertEqual(
      UserFacingErrorMessage.text(for: NetworkError.invalidURL),
      "Invalid request URL."
    )
    XCTAssertEqual(
      UserFacingErrorMessage.text(for: NetworkError.httpStatus(404)),
      "Request failed (HTTP 404)."
    )
    XCTAssertEqual(
      UserFacingErrorMessage.text(for: NetworkError.decoding(DecodingError.dataCorrupted(.init(codingPath: [], debugDescription: "")))),
      "Could not read movie data."
    )
    XCTAssertEqual(
      UserFacingErrorMessage.text(for: NetworkError.transport(URLError(.timedOut))),
      "Network connection failed."
    )
  }
}
