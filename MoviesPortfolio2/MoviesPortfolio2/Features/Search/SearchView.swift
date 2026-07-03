import MoviesCore
import SwiftUI

struct SearchView: View {
  @State private var viewModel: SearchViewModel
  private let imageCache: ImageCache
  private let makeMovieDetailsViewModel: (Int) -> MovieDetailsViewModel

  init(
    viewModel: SearchViewModel,
    imageCache: ImageCache,
    makeMovieDetailsViewModel: @escaping (Int) -> MovieDetailsViewModel
  ) {
    _viewModel = State(initialValue: viewModel)
    self.imageCache = imageCache
    self.makeMovieDetailsViewModel = makeMovieDetailsViewModel
  }

  var body: some View {
    SearchViewRepresentable(
      viewModel: viewModel,
      imageCache: imageCache,
      makeMovieDetailsViewModel: makeMovieDetailsViewModel
    )
  }
}

#Preview {
  let dependencies = AppDependencies()
  SearchView(
    viewModel: dependencies.makeSearchViewModel(),
    imageCache: dependencies.imageCache,
    makeMovieDetailsViewModel: dependencies.makeMovieDetailsViewModel(movieID:)
  )
}
