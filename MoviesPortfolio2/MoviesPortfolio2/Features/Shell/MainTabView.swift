import SwiftUI

struct MainTabView: View {
  let dependencies: AppDependencies

  var body: some View {
    TabView {
      TrendingView(
        viewModel: dependencies.makeTrendingViewModel(),
        makeMovieDetailsViewModel: dependencies.makeMovieDetailsViewModel(movieID:)
      )
        .tabItem {
          Label("Trending", systemImage: "flame")
        }

      SearchView(
        viewModel: dependencies.makeSearchViewModel(),
        imageCache: dependencies.imageCache,
        makeMovieDetailsViewModel: dependencies.makeMovieDetailsViewModel(movieID:)
      )
        .tabItem {
          Label("Search", systemImage: "magnifyingglass")
        }

      FavoritesView(
        viewModel: dependencies.makeFavoritesViewModel(),
        makeMovieDetailsViewModel: dependencies.makeMovieDetailsViewModel(movieID:)
      )
        .tabItem {
          Label("Favorites", systemImage: "heart")
        }

      SettingsView(dependencies: dependencies)
        .tabItem {
          Label("Settings", systemImage: "gearshape")
        }
    }
    .tint(Color.appAccent)
  }
}

#Preview {
  MainTabView(dependencies: AppDependencies())
}
