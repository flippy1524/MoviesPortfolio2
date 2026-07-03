import CoreData
import Foundation

@MainActor
final class PersistenceController {
  static let shared = PersistenceController()

  let container: NSPersistentContainer

  var viewContext: NSManagedObjectContext {
    container.viewContext
  }

  init(inMemory: Bool = false) {
    let model = CoreDataModelBuilder.makeModel()
    container = NSPersistentContainer(name: "MoviesPortfolio", managedObjectModel: model)

    if inMemory {
      container.persistentStoreDescriptions.first?.url = URL(fileURLWithPath: "/dev/null")
    }

    container.loadPersistentStores { _, error in
      if let error {
        assertionFailure("Unresolved Core Data error: \(error.localizedDescription)")
      }
    }

    container.viewContext.mergePolicy = NSMergePolicy(merge: .mergeByPropertyObjectTrumpMergePolicyType)
    container.viewContext.automaticallyMergesChangesFromParent = true
  }

  func saveIfNeeded() throws {
    let context = viewContext
    guard context.hasChanges else { return }
    try context.save()
  }
}
