import MoviesCore

struct UnavailableMovieDetailsRepository: MovieDetailsRepository {
  func fetchMovieDetails(id: Int) async throws -> MovieDetails {
    throw APIConfigurationError.missingAPIKey
  }

  func fetchCredits(id: Int) async throws -> Credits {
    throw APIConfigurationError.missingAPIKey
  }
}
