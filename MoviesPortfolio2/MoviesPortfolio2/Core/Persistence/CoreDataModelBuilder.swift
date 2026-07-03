import CoreData
import Foundation

enum CoreDataModelBuilder {
  static func makeModel() -> NSManagedObjectModel {
    let model = NSManagedObjectModel()

    let favorite = makeFavoriteMovieEntity()
    let trending = makeCachedTrendingSnapshotEntity()
    let details = makeCachedMovieDetailsEntity()

    model.entities = [favorite, trending, details]
    return model
  }

  private static func makeFavoriteMovieEntity() -> NSEntityDescription {
    let entity = NSEntityDescription()
    entity.name = "FavoriteMovieEntity"
    entity.managedObjectClassName = NSStringFromClass(FavoriteMovieEntity.self)

    entity.properties = [
      attribute(name: "movieID", type: .integer64AttributeType),
      attribute(name: "title", type: .stringAttributeType),
      attribute(name: "overview", type: .stringAttributeType),
      attribute(name: "posterPath", type: .stringAttributeType, optional: true),
      attribute(name: "backdropPath", type: .stringAttributeType, optional: true),
      attribute(name: "voteAverage", type: .doubleAttributeType, defaultValue: 0),
      attribute(name: "voteCount", type: .integer32AttributeType, defaultValue: 0),
      attribute(name: "releaseDate", type: .stringAttributeType, optional: true),
      attribute(name: "savedAt", type: .dateAttributeType)
    ]

    entity.uniquenessConstraints = [["movieID"]]

    return entity
  }

  private static func makeCachedTrendingSnapshotEntity() -> NSEntityDescription {
    let entity = NSEntityDescription()
    entity.name = "CachedTrendingSnapshotEntity"
    entity.managedObjectClassName = NSStringFromClass(CachedTrendingSnapshotEntity.self)

    entity.properties = [
      attribute(name: "snapshotID", type: .stringAttributeType),
      attribute(name: "moviesData", type: .binaryDataAttributeType),
      attribute(name: "page", type: .integer16AttributeType, defaultValue: 1),
      attribute(name: "totalPages", type: .integer16AttributeType, defaultValue: 1),
      attribute(name: "cachedAt", type: .dateAttributeType)
    ]

    return entity
  }

  private static func makeCachedMovieDetailsEntity() -> NSEntityDescription {
    let entity = NSEntityDescription()
    entity.name = "CachedMovieDetailsEntity"
    entity.managedObjectClassName = NSStringFromClass(CachedMovieDetailsEntity.self)

    entity.properties = [
      attribute(name: "movieID", type: .integer64AttributeType),
      attribute(name: "payloadData", type: .binaryDataAttributeType),
      attribute(name: "cachedAt", type: .dateAttributeType)
    ]

    entity.uniquenessConstraints = [["movieID"]]

    return entity
  }

  private static func attribute(
    name: String,
    type: NSAttributeType,
    optional: Bool = false,
    defaultValue: Any? = nil
  ) -> NSAttributeDescription {
    let attribute = NSAttributeDescription()
    attribute.name = name
    attribute.attributeType = type
    attribute.isOptional = optional
    attribute.defaultValue = defaultValue
    return attribute
  }
}
