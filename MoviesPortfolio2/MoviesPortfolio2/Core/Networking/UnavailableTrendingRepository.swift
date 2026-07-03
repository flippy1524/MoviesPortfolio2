import MoviesCore

struct UnavailableTrendingRepository: TrendingRepository {
  func fetchTrending(page: Int) async throws -> PaginatedResponse<Movie> {
    throw APIConfigurationError.missingAPIKey
  }
}
