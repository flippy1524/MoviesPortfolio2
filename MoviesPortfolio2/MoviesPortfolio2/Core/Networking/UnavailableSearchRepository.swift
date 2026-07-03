import MoviesCore

struct UnavailableSearchRepository: SearchRepository {
  func searchMovies(query: String, page: Int) async throws -> PaginatedResponse<Movie> {
    throw APIConfigurationError.missingAPIKey
  }

  func searchTV(query: String, page: Int) async throws -> PaginatedResponse<TVSeries> {
    throw APIConfigurationError.missingAPIKey
  }
}
