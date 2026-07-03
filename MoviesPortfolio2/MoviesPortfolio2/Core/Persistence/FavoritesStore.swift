import CoreData
import Foundation
import MoviesCore

@MainActor
protocol FavoritesStoring {
  func fetchFavoriteIDs() throws -> Set<Int>
  func fetchFavorites() throws -> [MediaItemDisplayModel]
  func addFavorite(from movie: Movie) throws
  func removeFavorite(movieID: Int) throws
  func isFavorite(movieID: Int) throws -> Bool
}

@MainActor
final class CoreDataFavoritesStore: FavoritesStoring {
  private let persistence: PersistenceController

  init(persistence: PersistenceController = .shared) {
    self.persistence = persistence
  }

  func fetchFavoriteIDs() throws -> Set<Int> {
    let objects = try fetchFavoriteObjects()
    return Set(objects.map { Int($0.movieID) })
  }

  func fetchFavorites() throws -> [MediaItemDisplayModel] {
    try fetchFavoriteObjects().map { $0.toDisplayModel() }
  }

  func addFavorite(from movie: Movie) throws {
    let context = persistence.viewContext
    let object = try findFavorite(movieID: movie.id, in: context) ?? FavoriteMovieEntity(context: context)
    object.movieID = Int64(movie.id)
    object.title = movie.title
    object.overview = movie.overview
    object.posterPath = movie.posterPath
    object.backdropPath = movie.backdropPath
    object.voteAverage = movie.voteAverage
    object.voteCount = Int32(movie.voteCount)
    object.releaseDate = movie.releaseDate
    object.savedAt = Date()
    try persistence.saveIfNeeded()
  }

  func removeFavorite(movieID: Int) throws {
    let context = persistence.viewContext
    if let object = try findFavorite(movieID: movieID, in: context) {
      context.delete(object)
      try persistence.saveIfNeeded()
    }
  }

  func isFavorite(movieID: Int) throws -> Bool {
    try findFavorite(movieID: movieID, in: persistence.viewContext) != nil
  }

  private func fetchFavoriteObjects() throws -> [FavoriteMovieEntity] {
    let request = NSFetchRequest<FavoriteMovieEntity>(entityName: "FavoriteMovieEntity")
    request.sortDescriptors = [NSSortDescriptor(key: "savedAt", ascending: false)]
    return try persistence.viewContext.fetch(request)
  }

  private func findFavorite(movieID: Int, in context: NSManagedObjectContext) throws -> FavoriteMovieEntity? {
    let request = NSFetchRequest<FavoriteMovieEntity>(entityName: "FavoriteMovieEntity")
    request.fetchLimit = 1
    request.predicate = NSPredicate(format: "movieID == %lld", Int64(movieID))
    return try context.fetch(request).first
  }
}

private extension FavoriteMovieEntity {
  func toDisplayModel() -> MediaItemDisplayModel {
    MediaItemDisplayModel(
      id: Int(movieID),
      title: title,
      overview: overview,
      posterPath: posterPath,
      isFavorite: true
    )
  }
}
