import CoreData
import Foundation
import MoviesCore

@objc(FavoriteMovieEntity)
final class FavoriteMovieEntity: NSManagedObject {
  @NSManaged var movieID: Int64
  @NSManaged var title: String
  @NSManaged var overview: String
  @NSManaged var posterPath: String?
  @NSManaged var backdropPath: String?
  @NSManaged var voteAverage: Double
  @NSManaged var voteCount: Int32
  @NSManaged var releaseDate: String?
  @NSManaged var savedAt: Date
}

@objc(CachedTrendingSnapshotEntity)
final class CachedTrendingSnapshotEntity: NSManagedObject {
  @NSManaged var snapshotID: String
  @NSManaged var moviesData: Data
  @NSManaged var page: Int16
  @NSManaged var totalPages: Int16
  @NSManaged var cachedAt: Date
}

@objc(CachedMovieDetailsEntity)
final class CachedMovieDetailsEntity: NSManagedObject {
  @NSManaged var movieID: Int64
  @NSManaged var payloadData: Data
  @NSManaged var cachedAt: Date
}

struct CachedMovieDetailsPayload: Codable, Sendable, Equatable {
  let details: MovieDetails
  let credits: Credits
}
