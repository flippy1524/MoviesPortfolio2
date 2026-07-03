import MoviesCore
import UIKit

@MainActor
protocol SearchViewControllerDelegate: AnyObject {
  func searchViewController(_ controller: SearchViewController, didSelectMovie id: Int)
  func searchViewControllerDidSelectTVSeries(_ controller: SearchViewController)
}

@MainActor
final class SearchViewController: UIViewController {
  weak var delegate: SearchViewControllerDelegate?

  private let viewModel: SearchViewModel
  private let imageCache: ImageCache
  private let tableView = UITableView(frame: .zero, style: .plain)
  private let mediaTypeControl = UISegmentedControl(items: ["Movies", "TV"])
  private let spinner = UIActivityIndicatorView(style: .medium)
  private let messageLabel: UILabel = {
    let label = UILabel()
    label.font = .preferredFont(forTextStyle: .subheadline)
    label.textColor = AppColors.secondaryText
    label.textAlignment = .center
    label.numberOfLines = 0
    label.isHidden = true
    label.translatesAutoresizingMaskIntoConstraints = false
    return label
  }()

  init(viewModel: SearchViewModel, imageCache: ImageCache) {
    self.viewModel = viewModel
    self.imageCache = imageCache
    super.init(nibName: nil, bundle: nil)
  }

  @available(*, unavailable)
  required init?(coder: NSCoder) {
    nil
  }

  override func viewDidLoad() {
    super.viewDidLoad()
    title = "Search"
    view.backgroundColor = AppColors.background
    configureHeader()
    configureTableView()
    configureSearchController()
    configureSpinner()
    configureMessageLabel()
    viewModel.onChange = { [weak self] in
      self?.reloadContent()
    }
    reloadContent()
  }

  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    viewModel.syncFavoriteState()
  }

  func reloadContent() {
    tableView.reloadData()
    updateLoadingState()
    updateMessage()
  }

  private func configureHeader() {
    mediaTypeControl.selectedSegmentIndex = viewModel.mediaType == .movie ? 0 : 1
    mediaTypeControl.addTarget(self, action: #selector(mediaTypeChanged), for: .valueChanged)
    mediaTypeControl.translatesAutoresizingMaskIntoConstraints = false

    let header = UIView(frame: CGRect(x: 0, y: 0, width: 0, height: 56))
    header.addSubview(mediaTypeControl)
    NSLayoutConstraint.activate([
      mediaTypeControl.leadingAnchor.constraint(equalTo: header.leadingAnchor, constant: AppSpacing.lg),
      mediaTypeControl.trailingAnchor.constraint(equalTo: header.trailingAnchor, constant: -AppSpacing.lg),
      mediaTypeControl.centerYAnchor.constraint(equalTo: header.centerYAnchor)
    ])
    tableView.tableHeaderView = header
  }

  private func configureTableView() {
    tableView.backgroundColor = AppColors.background
    tableView.separatorColor = AppColors.cardBackground
    tableView.rowHeight = UITableView.automaticDimension
    tableView.estimatedRowHeight = 104
    tableView.dataSource = self
    tableView.delegate = self
    tableView.register(MediaSearchResultCell.self, forCellReuseIdentifier: MediaSearchResultCell.reuseIdentifier)
    tableView.translatesAutoresizingMaskIntoConstraints = false
    view.addSubview(tableView)

    NSLayoutConstraint.activate([
      tableView.topAnchor.constraint(equalTo: view.topAnchor),
      tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
      tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
      tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
    ])
  }

  private func configureSearchController() {
    let searchController = UISearchController(searchResultsController: nil)
    searchController.obscuresBackgroundDuringPresentation = false
    searchController.searchResultsUpdater = self
    searchController.searchBar.placeholder = "Search movies and TV"
    navigationItem.searchController = searchController
    navigationItem.hidesSearchBarWhenScrolling = false
    definesPresentationContext = true
  }

  private func configureSpinner() {
    spinner.hidesWhenStopped = true
    spinner.translatesAutoresizingMaskIntoConstraints = false
    view.addSubview(spinner)
    NSLayoutConstraint.activate([
      spinner.centerXAnchor.constraint(equalTo: view.centerXAnchor),
      spinner.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: AppSpacing.xl)
    ])
  }

  private func configureMessageLabel() {
    view.addSubview(messageLabel)
    NSLayoutConstraint.activate([
      messageLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: AppSpacing.xl),
      messageLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -AppSpacing.xl),
      messageLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor)
    ])
  }

  private func updateLoadingState() {
    if viewModel.isLoading {
      spinner.startAnimating()
    } else {
      spinner.stopAnimating()
    }
  }

  private func updateMessage() {
    if viewModel.isLoading {
      messageLabel.isHidden = true
      return
    }

    if let errorMessage = viewModel.errorMessage, viewModel.results.isEmpty {
      messageLabel.text = errorMessage
      messageLabel.isHidden = false
      return
    }

    if viewModel.hasQuery, viewModel.results.isEmpty {
      messageLabel.text = "No results found."
      messageLabel.isHidden = false
      return
    }

    if !viewModel.hasQuery {
      messageLabel.text = "Search for movies or TV series."
      messageLabel.isHidden = false
      return
    }

    messageLabel.isHidden = true
  }

  @objc
  private func mediaTypeChanged() {
    let mediaType: SearchMediaType = mediaTypeControl.selectedSegmentIndex == 0 ? .movie : .tv
    viewModel.setMediaType(mediaType)
  }
}

extension SearchViewController: UITableViewDataSource {
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    viewModel.results.count
  }

  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    guard
      let cell = tableView.dequeueReusableCell(
        withIdentifier: MediaSearchResultCell.reuseIdentifier,
        for: indexPath
      ) as? MediaSearchResultCell
    else {
      return UITableViewCell()
    }

    let item = viewModel.results[indexPath.row]
    cell.configure(with: item)
    cell.onFavoriteTap = { [weak self] in
      self?.viewModel.toggleFavorite(for: item)
    }
    cell.setPosterImage(
      path: item.posterPath,
      layoutWidth: AppMetrics.searchPosterWidth,
      imageCache: imageCache
    )
    return cell
  }
}

extension SearchViewController: UITableViewDelegate {
  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    tableView.deselectRow(at: indexPath, animated: true)
    let item = viewModel.results[indexPath.row]
    switch item.kind {
    case .movie:
      delegate?.searchViewController(self, didSelectMovie: item.id)
    case .tv:
      delegate?.searchViewControllerDidSelectTVSeries(self)
    }
  }

  func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
    let item = viewModel.results[indexPath.row]
    viewModel.loadNextPageIfNeeded(currentItem: item)
  }
}

extension SearchViewController: UISearchResultsUpdating {
  func updateSearchResults(for searchController: UISearchController) {
    viewModel.updateQuery(searchController.searchBar.text ?? "")
  }
}
