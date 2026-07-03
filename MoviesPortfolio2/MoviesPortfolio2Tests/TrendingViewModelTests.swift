import XCTest
@testable import MoviesPortfolio2
import MoviesCore

@MainActor
final class TrendingViewModelTests: XCTestCase {
  private var favoritesStore: InMemoryFavoritesStore!
  private var favoritesRepository: FavoritesRepository!
  private var offlineStatus: OfflineStatus!

  override func setUp() async throws {
    favoritesStore = InMemoryFavoritesStore()
    favoritesRepository = FavoritesRepository(store: favoritesStore)
    offlineStatus = OfflineStatus()
  }

  func testLoadInitialPopulatesItems() async {
    let repository = MockTrendingRepository { _ in
      TestModelFactory.paginatedMovies([TestModelFactory.fightClub])
    }
    let viewModel = TrendingViewModel(
      repository: repository,
      favoritesRepository: favoritesRepository,
      offlineStatus: offlineStatus
    )

    viewModel.loadInitial()
    await AsyncTestSupport.waitUntil { !viewModel.isLoading }

    XCTAssertEqual(viewModel.items.count, 1)
    XCTAssertEqual(viewModel.items.first?.title, "Fight Club")
    XCTAssertNil(viewModel.errorMessage)
    XCTAssertFalse(viewModel.isOfflineFallback)
  }

  func testLoadInitialSetsErrorMessageOnFailure() async {
    let repository = MockTrendingRepository { _ in
      throw NetworkError.httpStatus(500)
    }
    let viewModel = TrendingViewModel(
      repository: repository,
      favoritesRepository: favoritesRepository,
      offlineStatus: offlineStatus
    )

    viewModel.loadInitial()
    await AsyncTestSupport.waitUntil { !viewModel.isLoading }

    XCTAssertTrue(viewModel.items.isEmpty)
    XCTAssertEqual(viewModel.errorMessage, "Request failed (HTTP 500).")
  }

  func testLoadNextPageAppendsResults() async {
    let tracker = RequestedPagesTracker()
    let repository = MockTrendingRepository { page in
      await tracker.record(page)
      switch page {
      case 1:
        return TestModelFactory.paginatedMovies([TestModelFactory.fightClub], page: 1, totalPages: 2)
      case 2:
        return TestModelFactory.paginatedMovies([TestModelFactory.matrix], page: 2, totalPages: 2)
      default:
        throw NetworkError.invalidResponse
      }
    }
    let viewModel = TrendingViewModel(
      repository: repository,
      favoritesRepository: favoritesRepository,
      offlineStatus: offlineStatus
    )

    viewModel.loadInitial()
    await AsyncTestSupport.waitUntil { !viewModel.isLoading && viewModel.items.count == 1 }

    viewModel.loadNextPage()
    await AsyncTestSupport.waitUntil { !viewModel.isLoadingMore && viewModel.items.count == 2 }

    let recordedPages = await tracker.recordedPages()
    XCTAssertEqual(recordedPages, [1, 2])
    XCTAssertEqual(viewModel.items.map(\.title), ["Fight Club", "The Matrix"])
  }

  func testToggleFavoriteUpdatesItemState() async {
    let repository = MockTrendingRepository { _ in
      TestModelFactory.paginatedMovies([TestModelFactory.fightClub])
    }
    let viewModel = TrendingViewModel(
      repository: repository,
      favoritesRepository: favoritesRepository,
      offlineStatus: offlineStatus
    )

    viewModel.loadInitial()
    await AsyncTestSupport.waitUntil { !viewModel.isLoading }

    let item = viewModel.items[0]
    XCTAssertFalse(item.isFavorite)

    viewModel.toggleFavorite(for: item)

    XCTAssertTrue(viewModel.items[0].isFavorite)
    XCTAssertTrue(favoritesRepository.isFavorite(movieID: 550))
  }

  func testOfflineFallbackReflectsOfflineStatus() async {
    offlineStatus.setTrendingFromCache(true)
    let repository = MockTrendingRepository { _ in
      TestModelFactory.paginatedMovies([TestModelFactory.fightClub])
    }
    let viewModel = TrendingViewModel(
      repository: repository,
      favoritesRepository: favoritesRepository,
      offlineStatus: offlineStatus
    )

    viewModel.loadInitial()
    await AsyncTestSupport.waitUntil { !viewModel.isLoading }

    XCTAssertTrue(viewModel.isOfflineFallback)
  }
}

private actor RequestedPagesTracker {
  private var pages: [Int] = []

  func record(_ page: Int) {
    pages.append(page)
  }

  func recordedPages() -> [Int] {
    pages
  }
}
