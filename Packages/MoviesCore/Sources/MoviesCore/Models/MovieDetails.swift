import Foundation

public struct MovieDetails: Codable, Sendable, Equatable, Identifiable {
    public let id: Int
    public let title: String
    public let overview: String
    public let posterPath: String?
    public let backdropPath: String?
    public let voteAverage: Double
    public let voteCount: Int
    public let releaseDate: String?
    public let runtime: Int?
    public let tagline: String?
    public let status: String?
    public let genres: [Genre]

    enum CodingKeys: String, CodingKey {
        case id
        case title
        case overview
        case posterPath = "poster_path"
        case backdropPath = "backdrop_path"
        case voteAverage = "vote_average"
        case voteCount = "vote_count"
        case releaseDate = "release_date"
        case runtime
        case tagline
        case status
        case genres
    }

    public init(
        id: Int,
        title: String,
        overview: String,
        posterPath: String?,
        backdropPath: String?,
        voteAverage: Double,
        voteCount: Int,
        releaseDate: String?,
        runtime: Int?,
        tagline: String?,
        status: String?,
        genres: [Genre]
    ) {
        self.id = id
        self.title = title
        self.overview = overview
        self.posterPath = posterPath
        self.backdropPath = backdropPath
        self.voteAverage = voteAverage
        self.voteCount = voteCount
        self.releaseDate = releaseDate
        self.runtime = runtime
        self.tagline = tagline
        self.status = status
        self.genres = genres
    }
}
