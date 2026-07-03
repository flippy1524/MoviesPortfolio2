import Foundation
import MoviesCore
import Observation

@MainActor
@Observable
final class FavoritesRepository {
  private(set) var favoriteIDs: Set<Int> = []

  private let store: FavoritesStoring

  init(store: FavoritesStoring) {
    self.store = store
    reload()
  }

  func reload() {
    favoriteIDs = (try? store.fetchFavoriteIDs()) ?? []
  }

  func fetchFavorites() throws -> [MediaItemDisplayModel] {
    try store.fetchFavorites()
  }

  func isFavorite(movieID: Int) -> Bool {
    favoriteIDs.contains(movieID)
  }

  func toggleFavorite(for item: MediaItemDisplayModel) {
    toggleFavorite(from: item.asMovie())
  }

  func toggleFavorite(from movie: Movie) {
    do {
      if favoriteIDs.contains(movie.id) {
        try store.removeFavorite(movieID: movie.id)
      } else {
        try store.addFavorite(from: movie)
      }
      reload()
    } catch {
      return
    }
  }

  func removeFavorite(movieID: Int) {
    do {
      try store.removeFavorite(movieID: movieID)
      reload()
    } catch {
      return
    }
  }

  func markFavorites(in items: [MediaItemDisplayModel]) -> [MediaItemDisplayModel] {
    items.map { item in
      var updated = item
      updated.isFavorite = favoriteIDs.contains(item.id)
      return updated
    }
  }
}
