import AsyncAlgorithms
import Foundation
import MoviesCore
import Observation

private final class DebounceCallbackBox: @unchecked Sendable {
  var onDebounced: (@MainActor () async -> Void)?
}

private final class SearchDebounceCoordinator {
  private let continuation: AsyncStream<Void>.Continuation
  private let task: Task<Void, Never>
  private let callbackBox: DebounceCallbackBox

  var onDebounced: (@MainActor () async -> Void)? {
    get { callbackBox.onDebounced }
    set { callbackBox.onDebounced = newValue }
  }

  init(interval: Duration) {
    let callbackBox = DebounceCallbackBox()
    self.callbackBox = callbackBox
    let (stream, continuation) = AsyncStream<Void>.makeStream()
    self.continuation = continuation
    task = Task {
      let debounced = stream.debounce(for: interval)
      for await _ in debounced {
        guard !Task.isCancelled else { return }
        await callbackBox.onDebounced?()
      }
    }
  }

  func schedule() {
    continuation.yield()
  }

  deinit {
    continuation.finish()
    task.cancel()
  }
}

@MainActor
@Observable
final class SearchViewModel {
  private(set) var results: [SearchResultDisplayModel] = []
  private(set) var mediaType: SearchMediaType = .movie
  private(set) var isLoading = false
  private(set) var isLoadingMore = false
  private(set) var errorMessage: String?

  var onChange: (() -> Void)?

  private var query = ""
  private var currentPage = 0
  private var totalPages = 1
  private var loadTask: Task<Void, Never>?
  private let debounceInterval: Duration = .milliseconds(400)
  private let debounceCoordinator: SearchDebounceCoordinator

  private let repository: SearchRepository
  private let favoritesRepository: FavoritesRepository

  var canLoadMore: Bool {
    currentPage < totalPages
  }

  var hasQuery: Bool {
    !trimmedQuery.isEmpty
  }

  private var trimmedQuery: String {
    query.trimmingCharacters(in: .whitespacesAndNewlines)
  }

  init(repository: SearchRepository, favoritesRepository: FavoritesRepository) {
    self.repository = repository
    self.favoritesRepository = favoritesRepository
    debounceCoordinator = SearchDebounceCoordinator(interval: debounceInterval)
    debounceCoordinator.onDebounced = { [weak self] in
      await self?.performSearch(reset: true)
    }
  }

  func setMediaType(_ mediaType: SearchMediaType) {
    guard self.mediaType != mediaType else { return }
    self.mediaType = mediaType
    scheduleSearch(reset: true)
    notifyChange()
  }

  func updateQuery(_ query: String) {
    self.query = query
    scheduleSearch(reset: true)
  }

  func loadNextPageIfNeeded(currentItem: SearchResultDisplayModel) {
    guard let lastItem = results.last, lastItem.id == currentItem.id else { return }
    loadNextPage()
  }

  func retry() {
    if trimmedQuery.isEmpty {
      return
    }
    if results.isEmpty {
      scheduleSearch(reset: true)
    } else {
      loadNextPage()
    }
  }

  func toggleFavorite(for item: SearchResultDisplayModel) {
    guard item.kind == .movie else { return }
    favoritesRepository.toggleFavorite(for: item.asMediaItem())
    results = markFavorites(in: results)
    notifyChange()
  }

  func syncFavoriteState() {
    results = markFavorites(in: results)
    notifyChange()
  }

  private func scheduleSearch(reset: Bool) {
    loadTask?.cancel()

    guard hasQuery else {
      results = []
      errorMessage = nil
      isLoading = false
      isLoadingMore = false
      currentPage = 0
      totalPages = 1
      notifyChange()
      return
    }

    if reset {
      isLoading = true
      errorMessage = nil
      currentPage = 0
      totalPages = 1
      notifyChange()
    }

    debounceCoordinator.schedule()
  }

  private func loadNextPage() {
    guard hasQuery, canLoadMore, !isLoading, !isLoadingMore else { return }
    loadTask = Task { await performSearch(reset: false) }
  }

  private func performSearch(reset: Bool) async {
    if reset {
      isLoading = true
      errorMessage = nil
      if currentPage == 0 {
        results = []
      }
    } else {
      isLoadingMore = true
    }

    defer {
      isLoading = false
      isLoadingMore = false
      notifyChange()
    }

    let page = reset ? 1 : currentPage + 1

    do {
      let newResults: [SearchResultDisplayModel]
      let responsePage: Int
      let responseTotalPages: Int

      switch mediaType {
      case .movie:
        let response = try await repository.searchMovies(query: trimmedQuery, page: page)
        guard !Task.isCancelled else { return }
        newResults = response.results.map { SearchResultDisplayModel(movie: $0) }
        responsePage = response.page
        responseTotalPages = response.totalPages
      case .tv:
        let response = try await repository.searchTV(query: trimmedQuery, page: page)
        guard !Task.isCancelled else { return }
        newResults = response.results.map { SearchResultDisplayModel(series: $0) }
        responsePage = response.page
        responseTotalPages = response.totalPages
      }

      if reset {
        results = markFavorites(in: newResults)
      } else {
        results.append(contentsOf: markFavorites(in: newResults))
      }

      currentPage = responsePage
      totalPages = responseTotalPages
      errorMessage = nil
    } catch {
      guard !Task.isCancelled else { return }
      errorMessage = UserFacingErrorMessage.text(for: error)
    }
  }

  private func notifyChange() {
    onChange?()
  }

  private func markFavorites(in items: [SearchResultDisplayModel]) -> [SearchResultDisplayModel] {
    items.map { item in
      var updated = item
      if item.kind == .movie {
        updated.isFavorite = favoritesRepository.isFavorite(movieID: item.id)
      }
      return updated
    }
  }
}
