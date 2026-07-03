import Foundation
import MoviesCore

enum InMemoryStoreError: Error {
  case failure
}

@MainActor
final class InMemoryFavoritesStore: FavoritesStoring {
  private var movies: [Int: Movie] = [:]
  var shouldThrowOnFetch = false

  func fetchFavoriteIDs() throws -> Set<Int> {
    if shouldThrowOnFetch { throw InMemoryStoreError.failure }
    return Set(movies.keys)
  }

  func fetchFavorites() throws -> [MediaItemDisplayModel] {
    if shouldThrowOnFetch { throw InMemoryStoreError.failure }
    return movies.values
      .sorted { $0.id < $1.id }
      .map { MediaItemDisplayModel(movie: $0, isFavorite: true) }
  }

  func addFavorite(from movie: Movie) throws {
    movies[movie.id] = movie
  }

  func removeFavorite(movieID: Int) throws {
    movies.removeValue(forKey: movieID)
  }

  func isFavorite(movieID: Int) throws -> Bool {
    movies[movieID] != nil
  }
}
