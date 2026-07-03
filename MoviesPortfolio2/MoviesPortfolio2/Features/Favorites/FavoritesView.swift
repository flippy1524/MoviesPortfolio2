import SwiftUI

struct FavoritesView: View {
  @Environment(\.horizontalSizeClass) private var horizontalSizeClass

  @State private var viewModel: FavoritesViewModel
  @State private var navigationPath = NavigationPath()
  private let makeMovieDetailsViewModel: (Int) -> MovieDetailsViewModel

  private var gridLayout: AdaptiveMovieGridLayout {
    AdaptiveMovieGridLayout.make(horizontalSizeClass: horizontalSizeClass)
  }

  init(
    viewModel: FavoritesViewModel,
    makeMovieDetailsViewModel: @escaping (Int) -> MovieDetailsViewModel
  ) {
    _viewModel = State(initialValue: viewModel)
    self.makeMovieDetailsViewModel = makeMovieDetailsViewModel
  }

  var body: some View {
    NavigationStack(path: $navigationPath) {
      content
        .background(Color.appBackground)
        .navigationTitle("Favorites")
        .navigationDestination(for: Int.self) { movieID in
          MovieDetailsView(viewModel: makeMovieDetailsViewModel(movieID))
        }
        .onAppear {
          viewModel.load()
        }
    }
  }

  @ViewBuilder
  private var content: some View {
    if viewModel.isLoading && viewModel.items.isEmpty {
      LoadingView(message: "Loading favorites…")
    } else if let errorMessage = viewModel.errorMessage, viewModel.items.isEmpty {
      ErrorStateView(message: errorMessage, onRetry: viewModel.refreshFromRepository)
    } else if viewModel.items.isEmpty {
      EmptyStateView(
        title: "No favorites yet",
        message: "Tap the heart on a movie to save it here."
      )
    } else {
      grid
    }
  }

  private var grid: some View {
    ScrollView {
      LazyVGrid(columns: gridLayout.columns, spacing: AppSpacing.lg) {
        ForEach(viewModel.items) { item in
          MovieCardView(item: item) {
            viewModel.removeFavorite(movieID: item.id)
          }
          .contentShape(Rectangle())
          .onTapGesture {
            navigationPath.append(item.id)
          }
        }
      }
      .padding(.horizontal, gridLayout.horizontalPadding)
      .padding(.vertical, AppSpacing.lg)
      .readableContentWidth(gridLayout.maxContentWidth)
    }
  }
}
