import Foundation
import MoviesCore

@MainActor
final class InMemoryOfflineCacheStore: OfflineCacheStoring {
  var cachedTrending: PaginatedResponse<Movie>?
  var cachedDetails: [Int: (MovieDetails, Credits)] = [:]
  var cacheDetailsError: Error?
  var fetchDetailsError: Error?

  func cacheTrending(_ response: PaginatedResponse<Movie>) throws {
    cachedTrending = response
  }

  func fetchCachedTrending() throws -> PaginatedResponse<Movie>? {
    cachedTrending
  }

  func cacheMovieDetails(_ details: MovieDetails, credits: Credits) throws {
    if let cacheDetailsError { throw cacheDetailsError }
    cachedDetails[details.id] = (details, credits)
  }

  func fetchCachedMovieDetails(movieID: Int) throws -> (MovieDetails, Credits)? {
    if let fetchDetailsError { throw fetchDetailsError }
    return cachedDetails[movieID]
  }
}
