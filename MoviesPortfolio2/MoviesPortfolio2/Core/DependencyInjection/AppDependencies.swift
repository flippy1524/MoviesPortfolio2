import Foundation
import MoviesCore
import Observation

@MainActor
@Observable
final class AppDependencies {
  let environment: AppEnvironment
  let apiConfiguration: APIConfiguration?
  let imageCache: ImageCache
  let favoritesRepository: FavoritesRepository
  let offlineStatus: OfflineStatus
  let trendingRepository: TrendingRepository
  let movieDetailsRepository: MovieDetailsRepository
  let searchRepository: SearchRepository

  private let offlineCache: OfflineCacheStoring

  var isAPIKeyConfigured: Bool {
    apiConfiguration != nil
  }

  init(bundle: Bundle = .main, persistence: PersistenceController = .shared) {
    environment = AppEnvironment.current(from: bundle)
    apiConfiguration = try? APIConfiguration.load(from: bundle)
    imageCache = ImageCache()

    let favoritesStore = CoreDataFavoritesStore(persistence: persistence)
    offlineCache = CoreDataOfflineCacheStore(persistence: persistence)
    favoritesRepository = FavoritesRepository(store: favoritesStore)
    offlineStatus = OfflineStatus()

    if let apiConfiguration {
      let client = URLSessionAPIClient(configuration: apiConfiguration)
      let liveTrending = LiveTrendingRepository(client: client)
      trendingRepository = CachingTrendingRepository(
        live: liveTrending,
        offlineCache: offlineCache,
        offlineStatus: offlineStatus
      )
      movieDetailsRepository = LiveMovieDetailsRepository(client: client)
      searchRepository = LiveSearchRepository(client: client)
    } else {
      trendingRepository = UnavailableTrendingRepository()
      movieDetailsRepository = UnavailableMovieDetailsRepository()
      searchRepository = UnavailableSearchRepository()
    }
  }

  func makeTrendingViewModel() -> TrendingViewModel {
    TrendingViewModel(
      repository: trendingRepository,
      favoritesRepository: favoritesRepository,
      offlineStatus: offlineStatus
    )
  }

  func makeMovieDetailsViewModel(movieID: Int) -> MovieDetailsViewModel {
    MovieDetailsViewModel(
      movieID: movieID,
      repository: movieDetailsRepository,
      favoritesRepository: favoritesRepository,
      offlineCache: offlineCache,
      offlineStatus: offlineStatus
    )
  }

  func makeSearchViewModel() -> SearchViewModel {
    SearchViewModel(
      repository: searchRepository,
      favoritesRepository: favoritesRepository
    )
  }

  func makeFavoritesViewModel() -> FavoritesViewModel {
    FavoritesViewModel(favoritesRepository: favoritesRepository)
  }
}
