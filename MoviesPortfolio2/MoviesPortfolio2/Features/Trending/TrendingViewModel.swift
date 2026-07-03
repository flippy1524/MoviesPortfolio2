import Foundation
import MoviesCore
import Observation

@MainActor
@Observable
final class TrendingViewModel {
  private(set) var items: [MediaItemDisplayModel] = []
  private(set) var isLoading = false
  private(set) var isLoadingMore = false
  private(set) var errorMessage: String?
  private(set) var isOfflineFallback = false

  private let repository: TrendingRepository
  private let favoritesRepository: FavoritesRepository
  private let offlineStatus: OfflineStatus
  private var currentPage = 0
  private var totalPages = 1
  private var loadTask: Task<Void, Never>?

  var canLoadMore: Bool {
    currentPage < totalPages
  }

  init(
    repository: TrendingRepository,
    favoritesRepository: FavoritesRepository,
    offlineStatus: OfflineStatus
  ) {
    self.repository = repository
    self.favoritesRepository = favoritesRepository
    self.offlineStatus = offlineStatus
  }

  func loadInitial() {
    loadTask?.cancel()
    loadTask = Task { await performLoad(reset: true) }
  }

  func loadNextPageIfNeeded(currentItem: MediaItemDisplayModel) {
    guard let lastItem = items.last, lastItem.id == currentItem.id else { return }
    loadNextPage()
  }

  func loadNextPage() {
    guard canLoadMore, !isLoading, !isLoadingMore else { return }
    loadTask = Task { await performLoad(reset: false) }
  }

  func retry() {
    if items.isEmpty {
      loadInitial()
    } else {
      loadNextPage()
    }
  }

  func toggleFavorite(for item: MediaItemDisplayModel) {
    favoritesRepository.toggleFavorite(for: item)
    items = favoritesRepository.markFavorites(in: items)
  }

  func syncFavorites() {
    items = favoritesRepository.markFavorites(in: items)
  }

  private func performLoad(reset: Bool) async {
    if reset {
      isLoading = true
      errorMessage = nil
      currentPage = 0
      totalPages = 1
      isOfflineFallback = false
    } else {
      isLoadingMore = true
    }

    defer {
      isLoading = false
      isLoadingMore = false
    }

    let page = reset ? 1 : currentPage + 1

    do {
      let response = try await repository.fetchTrending(page: page)
      guard !Task.isCancelled else { return }

      let newItems = favoritesRepository.markFavorites(
        in: response.results.map { MediaItemDisplayModel(movie: $0) }
      )
      if reset {
        items = newItems
      } else {
        items.append(contentsOf: newItems)
      }

      currentPage = response.page
      totalPages = response.totalPages
      errorMessage = nil
      isOfflineFallback = offlineStatus.isTrendingFromCache
    } catch {
      guard !Task.isCancelled else { return }
      errorMessage = UserFacingErrorMessage.text(for: error)
    }
  }
}
