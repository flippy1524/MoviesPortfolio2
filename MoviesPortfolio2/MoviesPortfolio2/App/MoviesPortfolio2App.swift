import MoviesCore
import SwiftUI

@main
struct MoviesPortfolio2App: App {
  @State private var dependencies = AppDependencies()

  var body: some Scene {
    WindowGroup {
      MainTabView(dependencies: dependencies)
        .environment(\.imageCache, dependencies.imageCache)
    }
  }
}
