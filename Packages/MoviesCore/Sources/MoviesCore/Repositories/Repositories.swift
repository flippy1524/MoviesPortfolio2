import Foundation

public protocol TrendingRepository: Sendable {
    func fetchTrending(page: Int) async throws -> PaginatedResponse<Movie>
}

public protocol MovieDetailsRepository: Sendable {
    func fetchMovieDetails(id: Int) async throws -> MovieDetails
    func fetchCredits(id: Int) async throws -> Credits
}

public enum SearchMediaType: Sendable, Equatable {
    case movie
    case tv
}

public protocol SearchRepository: Sendable {
    func searchMovies(query: String, page: Int) async throws -> PaginatedResponse<Movie>
    func searchTV(query: String, page: Int) async throws -> PaginatedResponse<TVSeries>
}

public struct LiveTrendingRepository: TrendingRepository, Sendable {
    private let client: APIClient

    public init(client: APIClient) {
        self.client = client
    }

    public func fetchTrending(page: Int) async throws -> PaginatedResponse<Movie> {
        try await client.request(.trendingMovies(page: page))
    }
}

public struct LiveMovieDetailsRepository: MovieDetailsRepository, Sendable {
    private let client: APIClient

    public init(client: APIClient) {
        self.client = client
    }

    public func fetchMovieDetails(id: Int) async throws -> MovieDetails {
        try await client.request(.movieDetails(id: id))
    }

    public func fetchCredits(id: Int) async throws -> Credits {
        try await client.request(.movieCredits(id: id))
    }
}

public struct LiveSearchRepository: SearchRepository, Sendable {
    private let client: APIClient

    public init(client: APIClient) {
        self.client = client
    }

    public func searchMovies(query: String, page: Int) async throws -> PaginatedResponse<Movie> {
        try await client.request(.searchMovies(query: query, page: page))
    }

    public func searchTV(query: String, page: Int) async throws -> PaginatedResponse<TVSeries> {
        try await client.request(.searchTV(query: query, page: page))
    }
}
