import Foundation
import MoviesCore

struct MockTrendingRepository: TrendingRepository {
  let handler: @Sendable (Int) async throws -> PaginatedResponse<Movie>

  func fetchTrending(page: Int) async throws -> PaginatedResponse<Movie> {
    try await handler(page)
  }
}

struct MockMovieDetailsRepository: MovieDetailsRepository {
  let detailsHandler: @Sendable (Int) async throws -> MovieDetails
  let creditsHandler: @Sendable (Int) async throws -> Credits

  init(
    details: @escaping @Sendable (Int) async throws -> MovieDetails,
    credits: @escaping @Sendable (Int) async throws -> Credits
  ) {
    detailsHandler = details
    creditsHandler = credits
  }

  func fetchMovieDetails(id: Int) async throws -> MovieDetails {
    try await detailsHandler(id)
  }

  func fetchCredits(id: Int) async throws -> Credits {
    try await creditsHandler(id)
  }
}

struct MockSearchRepository: SearchRepository {
  let moviesHandler: @Sendable (String, Int) async throws -> PaginatedResponse<Movie>
  let tvHandler: @Sendable (String, Int) async throws -> PaginatedResponse<TVSeries>

  init(
    movies: @escaping @Sendable (String, Int) async throws -> PaginatedResponse<Movie>,
    tv: @escaping @Sendable (String, Int) async throws -> PaginatedResponse<TVSeries>
  ) {
    moviesHandler = movies
    tvHandler = tv
  }

  func searchMovies(query: String, page: Int) async throws -> PaginatedResponse<Movie> {
    try await moviesHandler(query, page)
  }

  func searchTV(query: String, page: Int) async throws -> PaginatedResponse<TVSeries> {
    try await tvHandler(query, page)
  }
}
