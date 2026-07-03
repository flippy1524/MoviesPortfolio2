import Foundation
import MoviesCore
import Observation

@MainActor
@Observable
final class FavoritesViewModel {
  private(set) var items: [MediaItemDisplayModel] = []
  private(set) var isLoading = false
  private(set) var errorMessage: String?

  private let favoritesRepository: FavoritesRepository

  init(favoritesRepository: FavoritesRepository) {
    self.favoritesRepository = favoritesRepository
  }

  func load() {
    isLoading = true
    errorMessage = nil

    do {
      items = try favoritesRepository.fetchFavorites()
    } catch {
      errorMessage = "Could not load saved movies."
      items = []
    }

    isLoading = false
  }

  func removeFavorite(movieID: Int) {
    favoritesRepository.removeFavorite(movieID: movieID)
    items.removeAll { $0.id == movieID }
  }

  func refreshFromRepository() {
    load()
  }
}
