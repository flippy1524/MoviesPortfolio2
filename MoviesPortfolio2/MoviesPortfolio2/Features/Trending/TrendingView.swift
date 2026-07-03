import SwiftUI

struct TrendingView: View {
  @Environment(\.horizontalSizeClass) private var horizontalSizeClass

  @State private var viewModel: TrendingViewModel
  @State private var navigationPath = NavigationPath()
  private let makeMovieDetailsViewModel: (Int) -> MovieDetailsViewModel

  private var gridLayout: AdaptiveMovieGridLayout {
    AdaptiveMovieGridLayout.make(horizontalSizeClass: horizontalSizeClass)
  }

  init(
    viewModel: TrendingViewModel,
    makeMovieDetailsViewModel: @escaping (Int) -> MovieDetailsViewModel
  ) {
    _viewModel = State(initialValue: viewModel)
    self.makeMovieDetailsViewModel = makeMovieDetailsViewModel
  }

  var body: some View {
    NavigationStack(path: $navigationPath) {
      content
        .background(Color.appBackground)
        .navigationTitle("Trending")
        .navigationDestination(for: Int.self) { movieID in
          MovieDetailsView(viewModel: makeMovieDetailsViewModel(movieID))
        }
        .task {
          if viewModel.items.isEmpty {
            viewModel.loadInitial()
          }
        }
        .onAppear {
          viewModel.syncFavorites()
        }
    }
  }

  @ViewBuilder
  private var content: some View {
    if viewModel.isLoading && viewModel.items.isEmpty {
      LoadingView(message: "Loading trending movies…")
    } else if let errorMessage = viewModel.errorMessage, viewModel.items.isEmpty {
      ErrorStateView(message: errorMessage, onRetry: viewModel.retry)
    } else if viewModel.items.isEmpty {
      EmptyStateView(title: "No movies", message: "Nothing trending right now.")
    } else {
      grid
    }
  }

  private var grid: some View {
    VStack(spacing: 0) {
      if viewModel.isOfflineFallback {
        OfflineBannerView(message: "Showing cached trending movies.")
      }

      ScrollView {
        LazyVGrid(columns: gridLayout.columns, spacing: AppSpacing.lg) {
          ForEach(viewModel.items) { item in
            MovieCardView(item: item) {
              viewModel.toggleFavorite(for: item)
            }
            .contentShape(Rectangle())
            .onTapGesture {
              navigationPath.append(item.id)
            }
            .onAppear {
              viewModel.loadNextPageIfNeeded(currentItem: item)
            }
          }
        }
        .padding(.horizontal, gridLayout.horizontalPadding)
        .padding(.vertical, AppSpacing.lg)
        .readableContentWidth(gridLayout.maxContentWidth)
        .animation(.none, value: viewModel.items.count)

        if viewModel.isLoadingMore {
          ProgressView()
            .padding(.bottom, AppSpacing.lg)
        }
      }
    }
    .overlay(alignment: .bottom) {
      if let errorMessage = viewModel.errorMessage, !viewModel.items.isEmpty {
        paginationErrorBanner(message: errorMessage)
      }
    }
  }

  private func paginationErrorBanner(message: String) -> some View {
    HStack(spacing: AppSpacing.md) {
      Text(message)
        .font(AppTypography.caption)
        .foregroundStyle(Color.appPrimaryText)
        .lineLimit(2)

      Button("Retry", action: viewModel.retry)
        .font(AppTypography.caption.weight(.semibold))
    }
    .padding(AppSpacing.md)
    .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: AppMetrics.cornerRadius))
    .padding(AppSpacing.lg)
  }
}

#Preview {
  let dependencies = AppDependencies()
  TrendingView(
    viewModel: dependencies.makeTrendingViewModel(),
    makeMovieDetailsViewModel: dependencies.makeMovieDetailsViewModel(movieID:)
  )
}
