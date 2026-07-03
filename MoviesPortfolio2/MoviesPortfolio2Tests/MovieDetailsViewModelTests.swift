import XCTest
@testable import MoviesPortfolio2
import MoviesCore

@MainActor
final class MovieDetailsViewModelTests: XCTestCase {
  private var favoritesStore: InMemoryFavoritesStore!
  private var favoritesRepository: FavoritesRepository!
  private var offlineCache: InMemoryOfflineCacheStore!
  private var offlineStatus: OfflineStatus!

  override func setUp() async throws {
    favoritesStore = InMemoryFavoritesStore()
    favoritesRepository = FavoritesRepository(store: favoritesStore)
    offlineCache = InMemoryOfflineCacheStore()
    offlineStatus = OfflineStatus()
  }

  func testLoadPopulatesDetails() async {
    let repository = MockMovieDetailsRepository(
      details: { _ in TestModelFactory.fightClubDetails },
      credits: { _ in TestModelFactory.fightClubCredits }
    )
    let viewModel = makeViewModel(repository: repository)

    viewModel.load()
    await AsyncTestSupport.waitUntil { !viewModel.isLoading && viewModel.details != nil }

    XCTAssertEqual(viewModel.details?.title, "Fight Club")
    XCTAssertEqual(viewModel.details?.runtimeText, "2h 19m")
    XCTAssertEqual(viewModel.details?.directors, ["David Fincher"])
    XCTAssertEqual(viewModel.details?.cast.count, 2)
    XCTAssertNil(viewModel.errorMessage)
    XCTAssertFalse(viewModel.isOfflineFallback)
    XCTAssertEqual(offlineCache.cachedDetails[550]?.0.title, "Fight Club")
  }

  func testLoadFallsBackToCachedDetailsOnNetworkFailure() async {
    offlineCache.cachedDetails[550] = (TestModelFactory.fightClubDetails, TestModelFactory.fightClubCredits)
    let repository = MockMovieDetailsRepository(
      details: { _ in throw NetworkError.transport(URLError(.notConnectedToInternet)) },
      credits: { _ in throw NetworkError.transport(URLError(.notConnectedToInternet)) }
    )
    let viewModel = makeViewModel(repository: repository)

    viewModel.load()
    await AsyncTestSupport.waitUntil { !viewModel.isLoading && viewModel.details != nil }

    XCTAssertEqual(viewModel.details?.title, "Fight Club")
    XCTAssertTrue(viewModel.isOfflineFallback)
    XCTAssertNil(viewModel.errorMessage)
  }

  func testLoadSetsErrorWhenNetworkAndCacheFail() async {
    let repository = MockMovieDetailsRepository(
      details: { _ in throw NetworkError.httpStatus(503) },
      credits: { _ in throw NetworkError.httpStatus(503) }
    )
    let viewModel = makeViewModel(repository: repository)

    viewModel.load()
    await AsyncTestSupport.waitUntil { !viewModel.isLoading && viewModel.errorMessage != nil }

    XCTAssertNil(viewModel.details)
    XCTAssertEqual(viewModel.errorMessage, "Request failed (HTTP 503).")
  }

  func testToggleFavoriteUsesLoadedMovie() async {
    try? favoritesStore.addFavorite(from: TestModelFactory.fightClub)
    favoritesRepository.reload()

    let repository = MockMovieDetailsRepository(
      details: { _ in TestModelFactory.fightClubDetails },
      credits: { _ in TestModelFactory.fightClubCredits }
    )
    let viewModel = makeViewModel(repository: repository)

    viewModel.load()
    await AsyncTestSupport.waitUntil { !viewModel.isLoading }

    XCTAssertTrue(viewModel.isFavorite)

    viewModel.toggleFavorite()

    XCTAssertFalse(viewModel.isFavorite)
    XCTAssertFalse(favoritesRepository.isFavorite(movieID: 550))
  }

  private func makeViewModel(repository: MovieDetailsRepository) -> MovieDetailsViewModel {
    MovieDetailsViewModel(
      movieID: 550,
      repository: repository,
      favoritesRepository: favoritesRepository,
      offlineCache: offlineCache,
      offlineStatus: offlineStatus
    )
  }
}
