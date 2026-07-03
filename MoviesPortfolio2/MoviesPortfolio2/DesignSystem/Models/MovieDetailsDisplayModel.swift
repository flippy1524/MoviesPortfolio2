import Foundation
import MoviesCore

struct MovieDetailsDisplayModel: Equatable, Sendable {
  struct CastItem: Identifiable, Equatable, Sendable {
    let id: Int
    let name: String
    let role: String
    let profilePath: String?
  }

  let id: Int
  let title: String
  let overview: String
  let posterPath: String?
  let backdropPath: String?
  let ratingText: String
  let voteCountText: String
  let releaseDateText: String?
  let runtimeText: String?
  let tagline: String?
  let status: String?
  let genres: [String]
  let cast: [CastItem]
  let directors: [String]

  init(details: MovieDetails, credits: Credits) {
    id = details.id
    title = details.title
    overview = details.overview
    posterPath = details.posterPath
    backdropPath = details.backdropPath
    ratingText = String(format: "%.1f", details.voteAverage)
    voteCountText = Self.formattedVoteCount(details.voteCount)
    releaseDateText = Self.formattedReleaseDate(details.releaseDate)
    runtimeText = Self.formattedRuntime(details.runtime)
    tagline = details.tagline?.isEmpty == false ? details.tagline : nil
    status = details.status
    genres = details.genres.map(\.name)
    cast = credits.cast
      .sorted { $0.order < $1.order }
      .prefix(20)
      .map { member in
        CastItem(
          id: member.id,
          name: member.name,
          role: member.character,
          profilePath: member.profilePath
        )
      }
    directors = credits.crew
      .filter { $0.job == "Director" }
      .map(\.name)
  }

  private static func formattedVoteCount(_ count: Int) -> String {
    let formatter = NumberFormatter()
    formatter.numberStyle = .decimal
    return formatter.string(from: NSNumber(value: count)) ?? "\(count)"
  }

  private static func formattedReleaseDate(_ value: String?) -> String? {
    guard let value else { return nil }
    let input = DateFormatter()
    input.dateFormat = "yyyy-MM-dd"
    guard let date = input.date(from: value) else { return value }

    let output = DateFormatter()
    output.dateStyle = .medium
    return output.string(from: date)
  }

  private static func formattedRuntime(_ minutes: Int?) -> String? {
    guard let minutes, minutes > 0 else { return nil }
    let hours = minutes / 60
    let remainingMinutes = minutes % 60
    if hours > 0 {
      return "\(hours)h \(remainingMinutes)m"
    }
    return "\(remainingMinutes)m"
  }
}
