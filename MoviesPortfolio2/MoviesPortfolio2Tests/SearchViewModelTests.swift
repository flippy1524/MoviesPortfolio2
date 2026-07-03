import XCTest
@testable import MoviesPortfolio2
import MoviesCore

@MainActor
final class SearchViewModelTests: XCTestCase {
  private var favoritesStore: InMemoryFavoritesStore!
  private var favoritesRepository: FavoritesRepository!

  override func setUp() async throws {
    favoritesStore = InMemoryFavoritesStore()
    favoritesRepository = FavoritesRepository(store: favoritesStore)
  }

  func testEmptyQueryClearsResults() async {
    let viewModel = makeViewModel()

    viewModel.updateQuery("   ")
    try? await Task.sleep(for: .milliseconds(500))

    XCTAssertTrue(viewModel.results.isEmpty)
    XCTAssertFalse(viewModel.isLoading)
    XCTAssertNil(viewModel.errorMessage)
  }

  func testMovieSearchReturnsResultsAfterThrottle() async {
    let repository = MockSearchRepository(
      movies: { query, page in
        XCTAssertEqual(query, "fight")
        XCTAssertEqual(page, 1)
        return TestModelFactory.paginatedMovies([TestModelFactory.fightClub], page: page)
      },
      tv: { _, _ in TestModelFactory.paginatedTV([]) }
    )
    let viewModel = makeViewModel(repository: repository)

    viewModel.updateQuery("fight")
    await AsyncTestSupport.waitUntil(timeout: 3) { !viewModel.isLoading && !viewModel.results.isEmpty }

    XCTAssertEqual(viewModel.results.count, 1)
    XCTAssertEqual(viewModel.results.first?.title, "Fight Club")
    XCTAssertEqual(viewModel.results.first?.kind, .movie)
  }

  func testTVSearchUsesTVRepository() async {
    let repository = MockSearchRepository(
      movies: { _, _ in TestModelFactory.paginatedMovies([]) },
      tv: { query, page in
        XCTAssertEqual(query, "breaking")
        XCTAssertEqual(page, 1)
        return TestModelFactory.paginatedTV([TestModelFactory.breakingBad], page: page)
      }
    )
    let viewModel = makeViewModel(repository: repository)

    viewModel.setMediaType(.tv)
    viewModel.updateQuery("breaking")
    await AsyncTestSupport.waitUntil(timeout: 3) { !viewModel.isLoading && !viewModel.results.isEmpty }

    XCTAssertEqual(viewModel.results.first?.title, "Breaking Bad")
    XCTAssertEqual(viewModel.results.first?.kind, .tv)
  }

  func testToggleFavoriteOnlyAppliesToMovies() async {
    let repository = MockSearchRepository(
      movies: { _, _ in TestModelFactory.paginatedMovies([TestModelFactory.fightClub]) },
      tv: { _, _ in TestModelFactory.paginatedTV([]) }
    )
    let viewModel = makeViewModel(repository: repository)

    viewModel.updateQuery("fight")
    await AsyncTestSupport.waitUntil(timeout: 3) { !viewModel.results.isEmpty }

    viewModel.toggleFavorite(for: viewModel.results[0])
    XCTAssertTrue(viewModel.results[0].isFavorite)
  }

  func testToggleFavoriteIgnoresTVResults() async {
    let repository = MockSearchRepository(
      movies: { _, _ in TestModelFactory.paginatedMovies([]) },
      tv: { _, _ in TestModelFactory.paginatedTV([TestModelFactory.breakingBad]) }
    )
    let viewModel = makeViewModel(repository: repository)

    viewModel.setMediaType(.tv)
    viewModel.updateQuery("breaking")
    await AsyncTestSupport.waitUntil(timeout: 3) { !viewModel.results.isEmpty }

    viewModel.toggleFavorite(for: viewModel.results[0])
    XCTAssertFalse(viewModel.results[0].isFavorite)
  }

  func testSearchFailureSetsErrorMessage() async {
    let repository = MockSearchRepository(
      movies: { _, _ in throw NetworkError.decoding(DecodingError.dataCorrupted(.init(codingPath: [], debugDescription: ""))) },
      tv: { _, _ in TestModelFactory.paginatedTV([]) }
    )
    let viewModel = makeViewModel(repository: repository)

    viewModel.updateQuery("broken")
    await AsyncTestSupport.waitUntil(timeout: 3) { viewModel.errorMessage != nil }

    XCTAssertEqual(viewModel.errorMessage, "Could not read movie data.")
    XCTAssertTrue(viewModel.results.isEmpty)
  }

  private func makeViewModel(repository: SearchRepository? = nil) -> SearchViewModel {
    SearchViewModel(
      repository: repository ?? MockSearchRepository(
        movies: { _, _ in TestModelFactory.paginatedMovies([]) },
        tv: { _, _ in TestModelFactory.paginatedTV([]) }
      ),
      favoritesRepository: favoritesRepository
    )
  }
}
