import MoviesCore
import SwiftUI
import UIKit

struct SearchViewRepresentable: UIViewControllerRepresentable {
  let viewModel: SearchViewModel
  let imageCache: ImageCache
  let makeMovieDetailsViewModel: (Int) -> MovieDetailsViewModel

  func makeUIViewController(context: Context) -> UINavigationController {
    let searchController = SearchViewController(viewModel: viewModel, imageCache: imageCache)
    searchController.delegate = context.coordinator
    let navigationController = UINavigationController(rootViewController: searchController)
    context.coordinator.navigationController = navigationController
    context.coordinator.imageCache = imageCache
    return navigationController
  }

  func updateUIViewController(_ uiViewController: UINavigationController, context: Context) {
    context.coordinator.navigationController = uiViewController
    context.coordinator.imageCache = imageCache
  }

  func makeCoordinator() -> Coordinator {
    Coordinator(makeMovieDetailsViewModel: makeMovieDetailsViewModel)
  }

  @MainActor
  final class Coordinator: NSObject, SearchViewControllerDelegate {
    weak var navigationController: UINavigationController?
    var imageCache: ImageCache?
    private let makeMovieDetailsViewModel: (Int) -> MovieDetailsViewModel

    init(makeMovieDetailsViewModel: @escaping (Int) -> MovieDetailsViewModel) {
      self.makeMovieDetailsViewModel = makeMovieDetailsViewModel
    }

    func searchViewController(_ controller: SearchViewController, didSelectMovie id: Int) {
      guard let imageCache else { return }
      let detailsView = MovieDetailsView(viewModel: makeMovieDetailsViewModel(id))
        .environment(\.imageCache, imageCache)
      let hostingController = UIHostingController(rootView: detailsView)
      navigationController?.pushViewController(hostingController, animated: true)
    }

    func searchViewControllerDidSelectTVSeries(_ controller: SearchViewController) {
      let alert = UIAlertController(
        title: "Unavailable",
        message: "TV series details are unavailable.",
        preferredStyle: .alert
      )
      alert.addAction(UIAlertAction(title: "OK", style: .default))
      navigationController?.present(alert, animated: true)
    }
  }
}
