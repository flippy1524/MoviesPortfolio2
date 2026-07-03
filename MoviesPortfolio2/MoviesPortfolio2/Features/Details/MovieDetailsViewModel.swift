import Foundation
import MoviesCore
import Observation

@MainActor
@Observable
final class MovieDetailsViewModel {
  let movieID: Int
  private(set) var details: MovieDetailsDisplayModel?
  private(set) var isLoading = false
  private(set) var errorMessage: String?
  private(set) var isOfflineFallback = false
  private(set) var isFavorite = false

  private let repository: MovieDetailsRepository
  private let favoritesRepository: FavoritesRepository
  private let offlineCache: OfflineCacheStoring
  private let offlineStatus: OfflineStatus
  private var loadedMovie: Movie?
  private var loadTask: Task<Void, Never>?

  init(
    movieID: Int,
    repository: MovieDetailsRepository,
    favoritesRepository: FavoritesRepository,
    offlineCache: OfflineCacheStoring,
    offlineStatus: OfflineStatus
  ) {
    self.movieID = movieID
    self.repository = repository
    self.favoritesRepository = favoritesRepository
    self.offlineCache = offlineCache
    self.offlineStatus = offlineStatus
  }

  func load() {
    loadTask?.cancel()
    loadTask = Task { await performLoad() }
  }

  func retry() {
    load()
  }

  func syncFavoriteState() {
    isFavorite = favoritesRepository.isFavorite(movieID: movieID)
  }

  func toggleFavorite() {
    guard let loadedMovie else { return }
    favoritesRepository.toggleFavorite(from: loadedMovie)
    syncFavoriteState()
  }

  private func performLoad() async {
    isLoading = true
    errorMessage = nil
    isOfflineFallback = false

    defer { isLoading = false }

    do {
      async let detailsRequest = repository.fetchMovieDetails(id: movieID)
      async let creditsRequest = repository.fetchCredits(id: movieID)
      let (movieDetails, credits) = try await (detailsRequest, creditsRequest)
      guard !Task.isCancelled else { return }

      try offlineCache.cacheMovieDetails(movieDetails, credits: credits)
      offlineStatus.setDetailsFromCache(false)
      loadedMovie = Movie(details: movieDetails)
      details = MovieDetailsDisplayModel(details: movieDetails, credits: credits)
      syncFavoriteState()
      isOfflineFallback = false
      errorMessage = nil
    } catch {
      guard !Task.isCancelled else { return }

      if let cached = try? offlineCache.fetchCachedMovieDetails(movieID: movieID) {
        loadedMovie = Movie(details: cached.0)
        details = MovieDetailsDisplayModel(details: cached.0, credits: cached.1)
        syncFavoriteState()
        offlineStatus.setDetailsFromCache(true)
        isOfflineFallback = true
        errorMessage = nil
      } else {
        errorMessage = UserFacingErrorMessage.text(for: error)
      }
    }
  }
}

private extension Movie {
  init(details: MovieDetails) {
    self.init(
      id: details.id,
      title: details.title,
      overview: details.overview,
      posterPath: details.posterPath,
      backdropPath: details.backdropPath,
      voteAverage: details.voteAverage,
      voteCount: details.voteCount,
      releaseDate: details.releaseDate
    )
  }
}
