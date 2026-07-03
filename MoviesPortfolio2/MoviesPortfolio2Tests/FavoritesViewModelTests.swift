import XCTest
@testable import MoviesPortfolio2
import MoviesCore

@MainActor
final class FavoritesViewModelTests: XCTestCase {
  private var favoritesStore: InMemoryFavoritesStore!
  private var favoritesRepository: FavoritesRepository!

  override func setUp() async throws {
    favoritesStore = InMemoryFavoritesStore()
    favoritesRepository = FavoritesRepository(store: favoritesStore)
  }

  func testLoadReturnsSavedFavorites() {
    try? favoritesStore.addFavorite(from: TestModelFactory.fightClub)
    try? favoritesStore.addFavorite(from: TestModelFactory.matrix)

    let viewModel = FavoritesViewModel(favoritesRepository: favoritesRepository)
    viewModel.load()

    XCTAssertEqual(viewModel.items.count, 2)
    XCTAssertEqual(viewModel.items.map(\.title), ["Fight Club", "The Matrix"])
    XCTAssertTrue(viewModel.items.allSatisfy(\.isFavorite))
    XCTAssertNil(viewModel.errorMessage)
    XCTAssertFalse(viewModel.isLoading)
  }

  func testLoadSetsErrorWhenStoreFails() {
    favoritesStore.shouldThrowOnFetch = true

    let viewModel = FavoritesViewModel(favoritesRepository: favoritesRepository)
    viewModel.load()

    XCTAssertTrue(viewModel.items.isEmpty)
    XCTAssertEqual(viewModel.errorMessage, "Could not load saved movies.")
  }

  func testRemoveFavoriteUpdatesList() {
    try? favoritesStore.addFavorite(from: TestModelFactory.fightClub)
    try? favoritesStore.addFavorite(from: TestModelFactory.matrix)

    let viewModel = FavoritesViewModel(favoritesRepository: favoritesRepository)
    viewModel.load()
    viewModel.removeFavorite(movieID: 550)

    XCTAssertEqual(viewModel.items.count, 1)
    XCTAssertEqual(viewModel.items.first?.id, 603)
    XCTAssertFalse(favoritesRepository.isFavorite(movieID: 550))
  }
}
