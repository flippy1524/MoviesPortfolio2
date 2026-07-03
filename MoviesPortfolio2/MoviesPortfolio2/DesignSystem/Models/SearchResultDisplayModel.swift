import Foundation
import MoviesCore

enum SearchResultKind: Sendable, Equatable {
  case movie
  case tv
}

struct SearchResultDisplayModel: Identifiable, Equatable, Sendable {
  let id: Int
  let title: String
  let overview: String
  let posterPath: String?
  let kind: SearchResultKind
  var isFavorite: Bool

  init(movie: Movie, isFavorite: Bool = false) {
    id = movie.id
    title = movie.title
    overview = movie.overview
    posterPath = movie.posterPath
    kind = .movie
    self.isFavorite = isFavorite
  }

  init(series: TVSeries, isFavorite: Bool = false) {
    id = series.id
    title = series.name
    overview = series.overview
    posterPath = series.posterPath
    kind = .tv
    self.isFavorite = isFavorite
  }

  func asMediaItem() -> MediaItemDisplayModel {
    MediaItemDisplayModel(
      id: id,
      title: title,
      overview: overview,
      posterPath: posterPath,
      isFavorite: isFavorite
    )
  }
}
