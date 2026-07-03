import Foundation

public struct TVSeries: Codable, Sendable, Equatable, Identifiable {
    public let id: Int
    public let name: String
    public let overview: String
    public let posterPath: String?
    public let backdropPath: String?
    public let voteAverage: Double
    public let voteCount: Int
    public let firstAirDate: String?

    enum CodingKeys: String, CodingKey {
        case id
        case name
        case overview
        case posterPath = "poster_path"
        case backdropPath = "backdrop_path"
        case voteAverage = "vote_average"
        case voteCount = "vote_count"
        case firstAirDate = "first_air_date"
    }

    public init(
        id: Int,
        name: String,
        overview: String,
        posterPath: String?,
        backdropPath: String?,
        voteAverage: Double,
        voteCount: Int,
        firstAirDate: String?
    ) {
        self.id = id
        self.name = name
        self.overview = overview
        self.posterPath = posterPath
        self.backdropPath = backdropPath
        self.voteAverage = voteAverage
        self.voteCount = voteCount
        self.firstAirDate = firstAirDate
    }
}
