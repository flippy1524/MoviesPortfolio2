import CoreData
import Foundation
import MoviesCore

@MainActor
protocol OfflineCacheStoring {
  func cacheTrending(_ response: PaginatedResponse<Movie>) throws
  func fetchCachedTrending() throws -> PaginatedResponse<Movie>?
  func cacheMovieDetails(_ details: MovieDetails, credits: Credits) throws
  func fetchCachedMovieDetails(movieID: Int) throws -> (MovieDetails, Credits)?
}

@MainActor
final class CoreDataOfflineCacheStore: OfflineCacheStoring {
  private static let trendingSnapshotID = "latest"

  private let persistence: PersistenceController
  private let encoder = JSONEncoder()
  private let decoder = JSONDecoder.tmdb

  init(persistence: PersistenceController = .shared) {
    self.persistence = persistence
  }

  func cacheTrending(_ response: PaginatedResponse<Movie>) throws {
    let context = persistence.viewContext
    let snapshot = try findTrendingSnapshot(in: context) ?? CachedTrendingSnapshotEntity(context: context)
    snapshot.snapshotID = Self.trendingSnapshotID
    snapshot.moviesData = try encoder.encode(response.results)
    snapshot.page = Int16(response.page)
    snapshot.totalPages = Int16(response.totalPages)
    snapshot.cachedAt = Date()
    try persistence.saveIfNeeded()
  }

  func fetchCachedTrending() throws -> PaginatedResponse<Movie>? {
    guard let snapshot = try findTrendingSnapshot(in: persistence.viewContext) else {
      return nil
    }

    let movies = try decoder.decode([Movie].self, from: snapshot.moviesData)
    guard !movies.isEmpty else { return nil }

    return PaginatedResponse(
      page: Int(snapshot.page),
      results: movies,
      totalPages: Int(snapshot.totalPages),
      totalResults: movies.count
    )
  }

  func cacheMovieDetails(_ details: MovieDetails, credits: Credits) throws {
    let context = persistence.viewContext
    let object = try findCachedDetails(movieID: details.id, in: context)
      ?? CachedMovieDetailsEntity(context: context)
    object.movieID = Int64(details.id)
    object.payloadData = try encoder.encode(CachedMovieDetailsPayload(details: details, credits: credits))
    object.cachedAt = Date()
    try persistence.saveIfNeeded()
  }

  func fetchCachedMovieDetails(movieID: Int) throws -> (MovieDetails, Credits)? {
    guard let object = try findCachedDetails(movieID: movieID, in: persistence.viewContext) else {
      return nil
    }

    let payload = try decoder.decode(CachedMovieDetailsPayload.self, from: object.payloadData)
    return (payload.details, payload.credits)
  }

  private func findTrendingSnapshot(in context: NSManagedObjectContext) throws -> CachedTrendingSnapshotEntity? {
    let request = NSFetchRequest<CachedTrendingSnapshotEntity>(entityName: "CachedTrendingSnapshotEntity")
    request.fetchLimit = 1
    request.predicate = NSPredicate(format: "snapshotID == %@", Self.trendingSnapshotID)
    return try context.fetch(request).first
  }

  private func findCachedDetails(
    movieID: Int,
    in context: NSManagedObjectContext
  ) throws -> CachedMovieDetailsEntity? {
    let request = NSFetchRequest<CachedMovieDetailsEntity>(entityName: "CachedMovieDetailsEntity")
    request.fetchLimit = 1
    request.predicate = NSPredicate(format: "movieID == %lld", Int64(movieID))
    return try context.fetch(request).first
  }
}
