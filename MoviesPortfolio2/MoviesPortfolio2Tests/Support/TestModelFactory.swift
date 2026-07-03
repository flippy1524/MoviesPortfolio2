import Foundation
import MoviesCore

enum TestModelFactory {
  static let fightClub = Movie(
    id: 550,
    title: "Fight Club",
    overview: "A ticking-time-bomb insomniac and a slippery soap salesman.",
    posterPath: "/pB8BM7pdDpEwFT5N9vrnGiJ6i0G.jpg",
    backdropPath: "/fCayJrkfRaCRCTh8GqN30f8oyQF.jpg",
    voteAverage: 8.433,
    voteCount: 26_280,
    releaseDate: "1999-10-15"
  )

  static let matrix = Movie(
    id: 603,
    title: "The Matrix",
    overview: "A computer hacker learns about the true nature of reality.",
    posterPath: "/matrix.jpg",
    backdropPath: "/matrix-backdrop.jpg",
    voteAverage: 8.2,
    voteCount: 24_000,
    releaseDate: "1999-03-31"
  )

  static let fightClubDetails = MovieDetails(
    id: 550,
    title: "Fight Club",
    overview: "A ticking-time-bomb insomniac and a slippery soap salesman.",
    posterPath: "/pB8BM7pdDpEwFT5N9vrnGiJ6i0G.jpg",
    backdropPath: "/fCayJrkfRaCRCTh8GqN30f8oyQF.jpg",
    voteAverage: 8.433,
    voteCount: 26_280,
    releaseDate: "1999-10-15",
    runtime: 139,
    tagline: "Mischief. Mayhem. Soap.",
    status: "Released",
    genres: [Genre(id: 18, name: "Drama")]
  )

  static let fightClubCredits = Credits(
    cast: [
      CastMember(id: 1, name: "Edward Norton", character: "The Narrator", profilePath: nil, order: 0),
      CastMember(id: 2, name: "Brad Pitt", character: "Tyler Durden", profilePath: nil, order: 1)
    ],
    crew: [
      CrewMember(id: 10, name: "David Fincher", job: "Director", department: "Directing", profilePath: nil)
    ]
  )

  static let breakingBad = TVSeries(
    id: 1396,
    name: "Breaking Bad",
    overview: "A chemistry teacher turned meth maker.",
    posterPath: "/bb.jpg",
    backdropPath: nil,
    voteAverage: 8.9,
    voteCount: 12_000,
    firstAirDate: "2008-01-20"
  )

  static func paginatedMovies(
    _ movies: [Movie],
    page: Int = 1,
    totalPages: Int = 1
  ) -> PaginatedResponse<Movie> {
    PaginatedResponse(
      page: page,
      results: movies,
      totalPages: totalPages,
      totalResults: movies.count
    )
  }

  static func paginatedTV(
    _ series: [TVSeries],
    page: Int = 1,
    totalPages: Int = 1
  ) -> PaginatedResponse<TVSeries> {
    PaginatedResponse(
      page: page,
      results: series,
      totalPages: totalPages,
      totalResults: series.count
    )
  }
}
