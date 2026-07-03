import Foundation
import MoviesCore

struct MediaItemDisplayModel: Identifiable, Equatable, Sendable {
  let id: Int
  let title: String
  let overview: String
  let posterPath: String?
  var isFavorite: Bool

  init(movie: Movie, isFavorite: Bool = false) {
    id = movie.id
    title = movie.title
    overview = movie.overview
    posterPath = movie.posterPath
    self.isFavorite = isFavorite
  }

  init(id: Int, title: String, overview: String, posterPath: String?, isFavorite: Bool) {
    self.id = id
    self.title = title
    self.overview = overview
    self.posterPath = posterPath
    self.isFavorite = isFavorite
  }

  func asMovie() -> Movie {
    Movie(
      id: id,
      title: title,
      overview: overview,
      posterPath: posterPath,
      backdropPath: nil,
      voteAverage: 0,
      voteCount: 0,
      releaseDate: nil
    )
  }
}
